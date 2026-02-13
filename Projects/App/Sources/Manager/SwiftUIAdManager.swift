import UIKit
import GADManager
import GoogleMobileAds

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

    @MainActor
    @discardableResult
    func show(unit: GADUnitName) async -> Bool {
        await withCheckedContinuation { continuation in
            guard let gadManager else {
                continuation.resume(returning: false)
                return
            }

            gadManager.show(unit: unit, isTesting: self.isTesting(unit: unit)) { _, _, result in
                continuation.resume(returning: result)
            }
        }
    }

    func isTesting(unit: GADUnitName) -> Bool {
        return testUnits.contains(unit)
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        guard let gadManager else {
            completion(false)
            return
        }

        gadManager.requestPermission { status in
            completion(status == .authorized)
        }
    }

    @discardableResult
    func requestAppTrackingIfNeed() async -> Bool {
        guard !LSDefaults.AdsTrackingRequested else { return false }
        guard LSDefaults.LaunchCount > 1 else { return false }

        return await withCheckedContinuation { continuation in
            self.requestPermission { granted in
                LSDefaults.AdsTrackingRequested = true
                continuation.resume(returning: granted)
            }
        }
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
