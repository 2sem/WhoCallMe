extension SwiftUIAdManager {
    enum GADUnitName: String {
        case full           = "FullAd"
        case homeBanner     = "HomeBanner"
        case settingsBanner = "SettingsBanner"
    }

#if DEBUG
    var testUnits: [GADUnitName] { [.full, .homeBanner, .settingsBanner] }
#else
    var testUnits: [GADUnitName] { [] }
#endif
}
