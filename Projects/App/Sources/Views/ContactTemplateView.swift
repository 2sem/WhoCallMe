import SwiftUI
import Contacts

struct ContactTemplateView: View {
    let contact: CNContact
    let originalImage: UIImage?
    let generatedImageData: Data?
    var isPreviewMode: Bool = false

    private var useThumbnail: Bool { !LSDefaults.needFullscreenPhoto }

    private var photo: UIImage? {
        if let originalImage {
            return originalImage
        }

        guard let data = contact.imageData else { return nil }

        if isPreviewMode, let generatedImageData, data == generatedImageData {
            return nil
        }

        return UIImage(data: data)
    }

    private var visibleRows: [InfoType] {
        var rows = InfoType.allCases

        if !useThumbnail {
            rows.removeAll { $0 == .photo }
        }

        if photo == nil {
            rows.removeAll { $0 == .photo }
        }

        if contact.organizationName.isEmpty || !LSDefaults.needPhotoContainsOrg {
            rows.removeAll { $0 == .organization }
        }

        if contact.departmentName.isEmpty || !LSDefaults.needPhotoContainsDept {
            rows.removeAll { $0 == .department }
        }

        if contact.jobTitle.isEmpty || !LSDefaults.needPhotoContainsJob {
            rows.removeAll { $0 == .jobTitle }
        }

        return rows
    }

    var body: some View {
        GeometryReader { proxy in
            let templateSize = CGSize(
                width: proxy.size.width * 0.85,
                height: proxy.size.height * 0.85
            )

            ZStack {
                Color.appNight
                    .ignoresSafeArea()

                templateBody(size: templateSize)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func templateBody(size: CGSize) -> some View {
        ZStack {
            if !useThumbnail, let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if isPreviewMode {
                Color.appNight.opacity(0.20)
            }

            VStack(spacing: 0) {
                Spacer().frame(height: size.height * 0.145)

                headerIcon

                if isPreviewMode {
                    Text(contact.fullName ?? "")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.appNightText)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.top, size.height * 0.035)

                    Text("Mobile Phone")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.appNightText)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                }

                infoRows
                    .padding(.top, 10)

                Spacer(minLength: 0)

                if isPreviewMode {
                    callCommandView
                        .padding(.bottom, size.height * 0.065)
                }
            }
            .padding(.horizontal, 2.5)
        }
        .frame(width: size.width, height: size.height)
    }

    private var headerIcon: some View {
        HStack {
            if let icon = UIImage(named: "icon.png") {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
            }
            Spacer()
        }
    }

    private var infoRows: some View {
        VStack(spacing: 0) {
            ForEach(visibleRows, id: \.self) { row in
                switch row {
                case .photo:
                    photoRow
                case .organization:
                    iconValueRow(iconName: "icon_company.png", value: contact.organizationName)
                case .department:
                    iconValueRow(iconName: "icon_team.png", value: contact.departmentName)
                case .jobTitle:
                    iconValueRow(iconName: "icon_position.png", value: contact.jobTitle)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.appNight2.opacity(0.22))
    }

    @ViewBuilder
    private var photoRow: some View {
        ZStack {
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }

    private func iconValueRow(iconName: String, value: String) -> some View {
        HStack(spacing: 8) {
            if let icon = UIImage(named: iconName) {
                Image(uiImage: icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.appNightText)
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }

            Text(value)
                .font(.system(size: 17))
                .foregroundStyle(Color.appNightText)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
    }

    private var callCommandView: some View {
        HStack(spacing: 0) {
            callCommandButton(
                iconName: "call_deny.png",
                title: "Deny",
                color: Color.appDestructive
            )

            Spacer(minLength: 0)

            callCommandButton(
                iconName: "call_allow.png",
                title: "Response",
                color: Color.appSuccess
            )
        }
        .frame(maxWidth: .infinity)
        .frame(width: 203)
    }

    private func callCommandButton(iconName: String, title: String, color: Color) -> some View {
        VStack(spacing: 7) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 61, height: 61)

                if let icon = UIImage(named: iconName) {
                    Image(uiImage: icon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.appNightText)
                        .frame(width: 30.5, height: 30.5)
                }
            }

            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(Color.appNightText)
        }
    }
}

private extension ContactTemplateView {
    enum InfoType: CaseIterable {
        case photo
        case organization
        case department
        case jobTitle
    }
}
