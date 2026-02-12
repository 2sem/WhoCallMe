import SwiftUI
import SwiftData

@main
struct WhoCallMeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
        .modelContainer(for: ContactBackup.self)
    }
}
