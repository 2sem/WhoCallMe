import SwiftUI

struct SettingsScreen: View {
    @AppStorage(LSDefaults.Keys.needGenerateNickname) private var needGenerateNickname = true
    @AppStorage(LSDefaults.Keys.needContainsOrg) private var needContainsOrg = true
    @AppStorage(LSDefaults.Keys.needContainsDept) private var needContainsDept = true
    @AppStorage(LSDefaults.Keys.needContainsJob) private var needContainsJob = true
    @AppStorage(LSDefaults.Keys.needMakeChoseong) private var needMakeChoseong = true
    @AppStorage(LSDefaults.Keys.needMakeIncomingPhoto) private var needMakeIncomingPhoto = true

    @AppStorage(LSDefaults.Keys.needFullscreenPhoto) private var needFullscreenPhoto = false
    @AppStorage(LSDefaults.Keys.needPhotoContainsOrg) private var needPhotoContainsOrg = true
    @AppStorage(LSDefaults.Keys.needPhotoContainsDept) private var needPhotoContainsDept = true
    @AppStorage(LSDefaults.Keys.needPhotoContainsJob) private var needPhotoContainsJob = true

    var body: some View {
        VStack(spacing: 0) {
        List {
            Section("SETTINGS_SECTION_CONTACTS") {
                Toggle("SETTINGS_GENERATE_NICKNAME", isOn: $needGenerateNickname)
                Toggle("SETTINGS_INCLUDE_COMPANY", isOn: $needContainsOrg)
                Toggle("SETTINGS_INCLUDE_DEPARTMENT", isOn: $needContainsDept)
                Toggle("SETTINGS_INCLUDE_JOB_TITLE", isOn: $needContainsJob)
                Toggle("SETTINGS_KOREAN_CONSONANT_SEARCH", isOn: $needMakeChoseong)
                Toggle("SETTINGS_GENERATE_INCOMING_SCREEN", isOn: $needMakeIncomingPhoto)
            }

            Section("SETTINGS_SECTION_INCOMING_SCREEN") {
                Toggle("SETTINGS_ORIGINAL_PHOTO_FULLSCREEN", isOn: $needFullscreenPhoto)
                    .disabled(!needMakeIncomingPhoto)
                Toggle("SETTINGS_INCOMING_INCLUDE_COMPANY", isOn: $needPhotoContainsOrg)
                    .disabled(!needMakeIncomingPhoto)
                Toggle("SETTINGS_INCOMING_INCLUDE_DEPARTMENT", isOn: $needPhotoContainsDept)
                    .disabled(!needMakeIncomingPhoto)
                Toggle("SETTINGS_INCOMING_INCLUDE_JOB_TITLE", isOn: $needPhotoContainsJob)
                    .disabled(!needMakeIncomingPhoto)
            }

            Section("SETTINGS_SECTION_APP_INFO") {
                LabeledContent("SETTINGS_APP_VERSION", value: Bundle.main.appVersion)
            }
        }
        .navigationTitle("SETTINGS_TITLE")
        .navigationBarTitleDisplayMode(.inline)

        BannerAdView(unitName: .settingsBanner)
        } // VStack
    }
}

private extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
}
