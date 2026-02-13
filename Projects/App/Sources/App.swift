import SwiftUI
import SwiftData
import GoogleMobileAds
import StoreKit

@main
struct WhoCallMeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var isSetupDone = false
    @State private var isLaunched = false
    @State private var isFromBackground = false
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var adManager = SwiftUIAdManager()

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(adManager)
                .task {
                    setupAds()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
        .modelContainer(for: ContactBackup.self)
    }

    // MARK: - AdMob

    private func setupAds() {
        guard !isSetupDone else { return }
        isSetupDone = true

        let mgr = adManager
        MobileAds.shared.start { _ in
            mgr.setup()

            #if DEBUG
            mgr.prepare(interstitialUnit: .full, interval: 60.0)
            #else
            mgr.prepare(interstitialUnit: .full, interval: 60.0 * 5)
            #endif
            mgr.canShowFirstTime = true
        }
    }

    // MARK: - Scene phase

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            isFromBackground = true
        case .active:
            handleAppDidBecomeActive()
        default:
            break
        }
    }

    private func handleAppDidBecomeActive() {
        let mgr = adManager
        Task { @MainActor in
            // Increment only once per cold launch, not on return from system alerts
            if !isLaunched {
                LSDefaults.increaseLaunchCount()
                isLaunched = true
                if LSDefaults.LaunchCount > 0 && LSDefaults.LaunchCount % 30 == 0 {
                    SKStoreReviewController.requestReview()
                }
            }

            // Request ATT only when returning from true background
            if isFromBackground {
                await mgr.requestAppTrackingIfNeed()
                isFromBackground = false
            }
        }
    }
}
