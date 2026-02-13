extension SwiftUIAdManager {
    enum GADUnitName: String {
        case full = "FullAd"
    }

#if DEBUG
    var testUnits: [GADUnitName] { [.full] }
#else
    var testUnits: [GADUnitName] { [] }
#endif
}
