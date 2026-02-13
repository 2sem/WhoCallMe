import Foundation
import CoreData
import SwiftData

@MainActor
struct DataMigrationManager {
    private static let migrationKey = "coreDataMigrationDone_v1"

    static func migrateIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        guard
            let modelURL = Bundle.main.url(forResource: "WhoCallMe", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        else { return }

        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        let coreDataContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        coreDataContext.persistentStoreCoordinator = psc

        let storeURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .last?
            .appendingPathComponent("WhoCallMe.sqlite")

        guard (try? psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                            configurationName: nil,
                                            at: storeURL,
                                            options: nil)) != nil
        else { return }

        let request = NSFetchRequest<NSManagedObject>(entityName: "OriginalContract")
        guard let records = try? coreDataContext.fetch(request) else { return }

        for record in records {
            let backup = ContactBackup(
                id: record.value(forKey: "id") as? String ?? "",
                storedDate: record.value(forKey: "storedDate") as? Date ?? Date()
            )
            backup.imageData = record.value(forKey: "imageData") as? Data
            backup.generatedImage = record.value(forKey: "generatedImage") as? Data
            backup.nickname = record.value(forKey: "nickname") as? String
            backup.generatedNickname = record.value(forKey: "generatedNickname") as? String
            backup.suffix = record.value(forKey: "suffix") as? String
            backup.generatedSuffix = record.value(forKey: "generatedSuffix") as? String
            context.insert(backup)
        }

        try? context.save()
        UserDefaults.standard.set(true, forKey: migrationKey)
    }
}
