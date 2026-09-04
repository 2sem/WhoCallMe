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
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        AppStore.requestReview(in: scene)
                    }
                }
            }

            if isFromBackground {
                isFromBackground = false
            }
        }

        // Request App Tracking Transparency on every activation once the scene
        // is active. Apple requires `UIApplication.State.active` when asking —
        // the `.active` scene phase satisfies that — but on a first cold launch
        // the splash is still settling, so wait a short beat before prompting.
        // `requestAppTrackingIfNeed()` guards on `.notDetermined`, so any call
        // after the user has answered is a cheap no-op (no double prompt).
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.5))
            await mgr.requestAppTrackingIfNeed()
        }
    }
}
