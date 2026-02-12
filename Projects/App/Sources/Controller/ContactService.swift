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
        try await convertContact(contact)
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
        let total = contacts.count

        for (i, contact) in contacts.enumerated() {
            guard !isCancelled() else { return }
            guard let target = contact.mutableCopy() as? CNMutableContact else { continue }
            let backup = backups.first { $0.id == contact.identifier }

            ContactConverter.restoreIndex(target, backup: backup)

            if backup?.isModified != true {
                target.imageData = backup?.imageData
            }

            try await ContactStore.shared.save(target)

            if let backup {
                modelContext.delete(backup)
            }

            onProgress(i + 1, total)
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
        } else {
            // Update original image if it changed
            let hasImage = contact.imageData != nil
            let hadImage = backup?.imageData != nil
            if hasImage != hadImage {
                backup?.imageData = contact.imageData
                backup?.isModified = true
            }
        }

        ContactConverter.generateIndex(target, backup: backup)

        // Image generation: Step 6b (requires ContactTemplateViewController rendering)
        // For now, preserve existing image behaviour
        if !LSDefaults.needMakeIncomingPhoto {
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

// MARK: - ContactBackup transient flag

extension ContactBackup {
    // Transient flag (not persisted) - mirrors OriginalContract.isModified
    var isModified: Bool {
        get { (UserDefaults.standard.object(forKey: "backup_modified_\(id)") as? Bool) ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "backup_modified_\(id)") }
    }
}
