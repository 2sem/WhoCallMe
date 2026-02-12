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
        List {
            Section("연락처") {
                Toggle("별명 생성", isOn: $needGenerateNickname)
                Toggle("회사명 포함", isOn: $needContainsOrg)
                Toggle("부서명 포함", isOn: $needContainsDept)
                Toggle("직책명 포함", isOn: $needContainsJob)
                Toggle("초성 검색(한국어)", isOn: $needMakeChoseong)
                Toggle("수신 화면 생성", isOn: $needMakeIncomingPhoto)
            }

            Section("수신화면") {
                Toggle("원본사진 전체화면", isOn: $needFullscreenPhoto)
                    .disabled(!needMakeIncomingPhoto)
                Toggle("수신화면에 회사명 포함", isOn: $needPhotoContainsOrg)
                    .disabled(!needMakeIncomingPhoto)
                Toggle("수신화면에 부서명 포함", isOn: $needPhotoContainsDept)
                    .disabled(!needMakeIncomingPhoto)
                Toggle("수신화면에 직책명 포함", isOn: $needPhotoContainsJob)
                    .disabled(!needMakeIncomingPhoto)
            }

            Section("앱 정보") {
                LabeledContent("앱 버전", value: Bundle.main.appVersion)
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
}
