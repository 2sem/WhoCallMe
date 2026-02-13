extension SwiftUIAdManager {
    enum GADUnitName: String {
        case full       = "FullAd"
        case homeBanner = "HomeBanner"
    }

#if DEBUG
    var testUnits: [GADUnitName] { [.full, .homeBanner] }
#else
    var testUnits: [GADUnitName] { [] }
#endif
}
