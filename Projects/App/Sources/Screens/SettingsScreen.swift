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
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                List {
                    Section {
                        settingsToggle("SETTINGS_GENERATE_NICKNAME", isOn: $needGenerateNickname)
                        settingsToggle("SETTINGS_INCLUDE_COMPANY", isOn: $needContainsOrg)
                        settingsToggle("SETTINGS_INCLUDE_DEPARTMENT", isOn: $needContainsDept)
                        settingsToggle("SETTINGS_INCLUDE_JOB_TITLE", isOn: $needContainsJob)
                        settingsToggle("SETTINGS_KOREAN_CONSONANT_SEARCH", isOn: $needMakeChoseong)
                        settingsToggle("SETTINGS_GENERATE_INCOMING_SCREEN", isOn: $needMakeIncomingPhoto)
                    } header: {
                        Text("SETTINGS_SECTION_CONTACTS")
                            .appEyebrow()
                            .foregroundStyle(Color.appTextTertiary)
                    }

                    Section {
                        settingsToggle(
                            "SETTINGS_ORIGINAL_PHOTO_FULLSCREEN",
                            isOn: $needFullscreenPhoto,
                            enabled: needMakeIncomingPhoto
                        )
                        settingsToggle(
                            "SETTINGS_INCOMING_INCLUDE_COMPANY",
                            isOn: $needPhotoContainsOrg,
                            enabled: needMakeIncomingPhoto
                        )
                        settingsToggle(
                            "SETTINGS_INCOMING_INCLUDE_DEPARTMENT",
                            isOn: $needPhotoContainsDept,
                            enabled: needMakeIncomingPhoto
                        )
                        settingsToggle(
                            "SETTINGS_INCOMING_INCLUDE_JOB_TITLE",
                            isOn: $needPhotoContainsJob,
                            enabled: needMakeIncomingPhoto
                        )
                    } header: {
                        Text("SETTINGS_SECTION_INCOMING_SCREEN")
                            .appEyebrow()
                            .foregroundStyle(Color.appTextTertiary)
                    }

                    Section {
                        LabeledContent("SETTINGS_APP_VERSION", value: Bundle.main.appVersion)
                            .foregroundStyle(Color.appTextSecondary)
                    } header: {
                        Text("SETTINGS_SECTION_APP_INFO")
                            .appEyebrow()
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }
                .listStyle(.insetGrouped)
                .tint(Color.appAmberDeep)

                BannerAdView(unitName: .settingsBanner)
            }
        }
        .navigationTitle("SETTINGS_TITLE")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func settingsToggle(
        _ title: LocalizedStringKey,
        isOn: Binding<Bool>,
        enabled: Bool = true
    ) -> some View {
        Toggle(title, isOn: isOn)
            .foregroundStyle(enabled ? Color.appTextPrimary : Color.appDisabled)
            .disabled(!enabled)
    }
}

private extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
}
