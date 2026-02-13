import UIKit
import Contacts
import SwiftData

@MainActor
final class ContactService: ObservableObject {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Convert All

    func convertAll(
        onProgress: (Int, Int) -> Void,
        isCancelled: () -> Bool
    ) async throws {
        try await ContactStore.shared.requestAccess()
        let contacts = try await ContactStore.shared.fetchAll(keys: ContactStore.keysForConvert)
        let total = contacts.count

        for (i, contact) in contacts.enumerated() {
            guard !isCancelled() else { return }
            try await convertContact(contact)
            onProgress(i + 1, total)
        }
    }

    // MARK: - Convert One

    func convertOne(_ contact: CNContact) async throws {
        try await ContactStore.shared.requestAccess()
        let results = try await ContactStore.shared.fetch(
            identifiers: [contact.identifier],
            keys: ContactStore.keysForConvert
        )
        guard let fullContact = results.first else { return }
        try await convertContact(fullContact)
    }

    // MARK: - Restore All

    func restoreAll(
        onProgress: (Int, Int) -> Void,
        isCancelled: () -> Bool
    ) async throws {
        try await ContactStore.shared.requestAccess()
        let backups = fetchAllBackups()
        let identifiers = backups.map { $0.id }
        let contacts = try await ContactStore.shared.fetch(
            identifiers: identifiers,
            keys: ContactStore.keysForConvert
        )
        let foundIDs = Set(contacts.map { $0.identifier })
        let total = contacts.count

        for (i, contact) in contacts.enumerated() {
            guard !isCancelled() else { return }
            guard let target = contact.mutableCopy() as? CNMutableContact else { continue }
            let backup = backups.first { $0.id == contact.identifier }

            ContactConverter.restoreIndex(target, backup: backup)

            // Only restore original if user hasn't manually changed the photo since conversion
            if contact.imageData == backup?.generatedImage {
                target.imageData = backup?.imageData
            }

            try await ContactStore.shared.save(target)

            if let backup {
                modelContext.delete(backup)
            }

            onProgress(i + 1, total)
        }

        // Delete orphaned backups whose contacts no longer exist in the store
        for backup in backups where !foundIDs.contains(backup.id) {
            modelContext.delete(backup)
        }

        try modelContext.save()
    }

    // MARK: - Clear All Photos

    func clearAllPhotos(
        onProgress: (Int, Int) -> Void,
        isCancelled: () -> Bool
    ) async throws {
        try await ContactStore.shared.requestAccess()
        let contacts = try await ContactStore.shared.fetchAll(keys: ContactStore.keysForClear)
        let total = contacts.count

        for (i, contact) in contacts.enumerated() {
            guard !isCancelled() else { return }
            guard let target = contact.mutableCopy() as? CNMutableContact else { continue }
            target.imageData = nil
            try await ContactStore.shared.save(target)
            onProgress(i + 1, total)
        }
    }

    // MARK: - Private

    private func convertContact(_ contact: CNContact) async throws {
        guard let target = contact.mutableCopy() as? CNMutableContact else { return }

        var backup = fetchBackup(for: contact.identifier)
        if backup == nil {
            backup = ContactBackup(id: contact.identifier)
            if let imageData = contact.imageData {
                backup?.imageData = imageData
            }
            if let backup { modelContext.insert(backup) }
        } else if contact.imageData != backup?.generatedImage {
            // User manually changed their photo since last conversion — track new original
            backup?.imageData = contact.imageData
        }

        ContactConverter.generateIndex(target, backup: backup)

        // Image generation via ContactTemplateViewController
        if LSDefaults.needMakeIncomingPhoto {
            let originalImage = backup?.imageData.flatMap { UIImage(data: $0) }
            if let rendered = ContactImageRenderer.render(contact: target, originalImage: originalImage) {
                target.imageData = rendered.pngData()
                backup?.generatedImage = target.imageData
            }
        } else {
            target.imageData = backup?.imageData
        }

        try await ContactStore.shared.save(target)
        try modelContext.save()
    }

    private func fetchBackup(for id: String) -> ContactBackup? {
        let descriptor = FetchDescriptor<ContactBackup>(
            predicate: #Predicate { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func fetchAllBackups() -> [ContactBackup] {
        let descriptor = FetchDescriptor<ContactBackup>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    var backupCount: Int {
        let descriptor = FetchDescriptor<ContactBackup>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }
}


