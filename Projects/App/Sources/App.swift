import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct WhoCallMeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var isSetupDone = false
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var adManager = SwiftUIAdManager()

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(adManager)
                .onAppear {
                    setupAds()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
        .modelContainer(for: ContactBackup.self)
    }

    private func setupAds() {
        guard !isSetupDone else { return }
        isSetupDone = true

        MobileAds.shared.start { _ in
            adManager.setup()

            #if DEBUG
            adManager.prepare(interstitialUnit: .full, interval: 60.0)
            #else
            adManager.prepare(interstitialUnit: .full, interval: 60.0 * 5)
            #endif
            adManager.canShowFirstTime = true
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        guard phase == .active else { return }
        LSDefaults.increaseLaunchCount()
        Task { await adManager.requestAppTrackingIfNeed() }
    }
}
