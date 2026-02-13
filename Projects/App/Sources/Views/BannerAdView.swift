import SwiftUI
import GoogleMobileAds

struct BannerAdView: View {
    let unitName: SwiftUIAdManager.GADUnitName

    @EnvironmentObject private var adManager: SwiftUIAdManager
    @State private var coordinator = BannerAdCoordinator()

    var body: some View {
        Group {
            if let bannerView = coordinator.bannerView {
                BannerAdRepresentable(bannerView: bannerView)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            } else {
                Color.clear.frame(height: 0)
            }
        }
        .onChange(of: adManager.isReady, initial: true) { _, isReady in
            guard isReady else { return }
            coordinator.load(withAdManager: adManager, unitName: unitName)
        }
    }
}

@Observable
final class BannerAdCoordinator: NSObject, BannerViewDelegate {
    var bannerView: BannerView?
    private var hasLoaded = false

    func load(withAdManager manager: SwiftUIAdManager, unitName: SwiftUIAdManager.GADUnitName) {
        guard !hasLoaded else { return }

        if let banner = manager.createBannerAdView(withAdSize: AdSizeBanner, forUnit: unitName) {
            banner.delegate = self
            self.bannerView = banner
            self.hasLoaded = true
            banner.load(Request())
        }
    }

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {}
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {}
}

private struct BannerAdRepresentable: UIViewRepresentable {
    let bannerView: BannerView

    func makeUIView(context: Context) -> BannerView { bannerView }
    func updateUIView(_ uiView: BannerView, context: Context) {}
}
