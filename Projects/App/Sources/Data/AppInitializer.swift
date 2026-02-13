import Foundation
import SwiftData

@MainActor
class AppInitializer: ObservableObject {
    @Published var isReady = false

    func initialize(context: ModelContext) async {
        DataMigrationManager.migrateIfNeeded(context: context)
        isReady = true
    }
}
