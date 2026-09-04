import UIKit
import GADManager
import GoogleMobileAds
import AppTrackingTransparency

class SwiftUIAdManager: NSObject, ObservableObject {
    private var gadManager: GADManager<GADUnitName>!
    var canShowFirstTime = true

    static var shared: SwiftUIAdManager?
    @Published var isReady: Bool = false

    func setup() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let adManager = GADManager<GADUnitName>(window)
        self.gadManager = adManager
        adManager.delegate = self

        SwiftUIAdManager.shared = self
        self.isReady = true
    }

    func createBannerAdView(withAdSize size: AdSize, forUnit unit: GADUnitName) -> BannerView? {
        gadManager?.prepare(bannerUnit: unit, isTesting: self.isTesting(unit: unit), size: size)
    }

    func prepare(interstitialUnit unit: GADUnitName, interval: TimeInterval) {
        gadManager?.prepare(interstitialUnit: unit, isTesting: self.isTesting(unit: unit), interval: interval)
    }

    /// Presents the interstitial for `unit` if one is loaded, then returns
    /// immediately — it does **not** wait for the ad to be dismissed.
    ///
    /// `force: true` bypasses `GADManager`'s frequency-cap interval (300 s in
    /// Release / 60 s in DEBUG) and the first-time gate, so a confirmed
    /// 2nd-or-later Convert All always shows the ad it promised the user.
    /// Still a silent no-op if no ad is loaded, there is no root view
    /// controller, or an alert is already presented.
    /// Callers use this to play the ad *over* other work rather than blocking
    /// on its dismissal.
    func showInterstitial(unit: GADUnitName) {
        gadManager?.show(unit: unit, force: true, isTesting: self.isTesting(unit: unit)) { _, _, _ in }
    }

    func isTesting(unit: GADUnitName) -> Bool {
        return testUnits.contains(unit)
    }

    @discardableResult
    func requestAppTrackingIfNeed() async -> Bool {
        // Only `.notDetermined` can still show the system prompt. Any other
        // status means the user already answered (or tracking is restricted),
        // so calling again would be a no-op. Gating on the real ATT status —
        // instead of the `AdsTrackingRequested` UserDefaults proxy — guarantees
        // a fresh install (reviewer included) always sees the prompt.
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return false }

        // Ask AppTrackingTransparency directly. Routing through GADManager tied
        // the prompt to the Mobile Ads SDK finishing `start(...)`, which on a
        // cold launch has not happened yet — that dependency is exactly what
        // hid the prompt from App Review.
        let status = await ATTrackingManager.requestTrackingAuthorization()
        LSDefaults.AdsTrackingRequested = true
        return status == .authorized
    }
}

extension SwiftUIAdManager: GADManagerDelegate {
    typealias E = GADUnitName

    func GAD<E>(manager: GADManager<E>, lastPreparedTimeForUnit unit: E) -> Date {
        return LSDefaults.LastOpeningAdPrepared
    }

    func GAD<E>(manager: GADManager<E>, updateLastPreparedTimeForUnit unit: E, preparedTime time: Date) {
        LSDefaults.LastOpeningAdPrepared = time
    }

    func GAD<E>(manager: GADManager<E>, lastShownTimeForUnit unit: E) -> Date {
        let now = Date()
        if LSDefaults.LastFullADShown > now {
            LSDefaults.LastFullADShown = now
        }
        return LSDefaults.LastFullADShown
    }

    func GAD<E>(manager: GADManager<E>, updatShownTimeForUnit unit: E, showTime time: Date) {
        LSDefaults.LastFullADShown = time
    }
}
