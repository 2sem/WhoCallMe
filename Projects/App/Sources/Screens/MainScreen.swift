import SwiftUI
import SwiftData
import Contacts
import FirebaseAnalytics

// MARK: - Main Screen

struct MainScreen: View {
    enum Mode { case convertAll, convertOne, restoreAll, previewOne, clearAll }
    enum OperationState { case ready, running, stopped, completed }

    @State private var mode: Mode = .convertAll
    @State private var operationState: OperationState = .ready
    @State private var progressedCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var isShowingContactPicker = false
    @State private var contactPickerMode: Mode = .convertOne
    @State private var previewContact: CNContact?

    @EnvironmentObject private var adManager: SwiftUIAdManager
    @AppStorage(LSDefaults.Keys.LaunchCount) private var launchCount: Int = 0

    @Environment(\.modelContext) private var modelContext
    @Query private var backups: [ContactBackup]
    @State private var contactService: ContactService?
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showRestoreConfirm = false
    @State private var showClearConfirm = false
    @State private var showConvertConfirm = false

    var isRunning: Bool { operationState == .running }

    var progress: Double {
        guard totalCount > 0 else { return 0.0 }
        let p = progressedCount
        return Double(max(0, p)) / Double(totalCount)
    }

    var statusText: String {
        switch operationState {
        case .ready: return ""
        case .stopped: return NSLocalizedString("STATUS_STOPPED", comment: "")
        case .running, .completed:
            switch mode {
            case .convertAll, .convertOne:
                return NSLocalizedString(operationState == .running ? "STATUS_CONVERTING" : "STATUS_CONVERTED", comment: "")
            case .restoreAll:
                return NSLocalizedString(operationState == .running ? "STATUS_RESTORING" : "STATUS_RESTORED", comment: "")
            case .clearAll:
                return NSLocalizedString(operationState == .running ? "STATUS_CLEARING" : "STATUS_CLEARED", comment: "")
            default: return ""
            }
        }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // Ambient glow behind ring
            RadialGradient(
                colors: [Color.appRingEnd.opacity(0.15), Color.clear],
                center: .center,
                startRadius: 60,
                endRadius: 200
            )
            .frame(width: 400, height: 400)
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        RingProgressView(progress: progress)
                            .frame(width: 240, height: 240)
                            .shadow(color: Color.appRingEnd.opacity(0.3), radius: 20)

                        VStack(spacing: 4) {
                            Text("\(progressedCount)")
                                .font(.system(size: 72, weight: .thin, design: .rounded))
                            if !statusText.isEmpty {
                                Text(statusText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    convertAllButton
                        .padding(.horizontal, 16)
                }

                Spacer()

                actionsCard
                    .padding(.horizontal, 16)

                Spacer()

                bottomBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                BannerAdView(unitName: .homeBanner)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $previewContact) { contact in
            PreviewScreen(contact: contact)
        }
        .onAppear {
            contactService = ContactService(modelContext: modelContext)
            progressedCount = backups.count
            Task {
                if let count = try? await ContactStore.shared.fetchCount() {
                    totalCount = max(count, backups.count)
                } else {
                    totalCount = backups.count
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .confirmationDialog(
            NSLocalizedString("WARN_RESTORE_CONTACTS_MSG", comment: ""),
            isPresented: $showRestoreConfirm,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("WARN_RESTORE_CONTACTS_RESTORE", comment: ""), role: .destructive) {
                Task { await runRestore() }
            }
        }
        .confirmationDialog(
            NSLocalizedString("WARN_CLEAR_PHOTOS_MSG", comment: ""),
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("WARN_CLEAR_PHOTOS_CLEAR", comment: ""), role: .destructive) {
                Task { await runClearPhotos() }
            }
        }
        .confirmationDialog(
            NSLocalizedString("WARN_CONVERT_ALL_MSG", comment: ""),
            isPresented: $showConvertConfirm,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("WARN_CONVERT_ALL_CONVERT", comment: "")) {
                presentFullAdThen { await startConvertAll() }
            }
        }
        .sheet(isPresented: $isShowingContactPicker) {
            ContactPickerView { contact in
                isShowingContactPicker = false
                guard let contact else { return }
                if contactPickerMode == .previewOne {
                    Analytics.logLeesamEvent(.previewCall)
                    previewContact = contact
                } else {
                    Task {
                        do {
                            Analytics.logLeesamEvent(.convertOne)
                            try await contactService?.convertOne(contact)
                            if let count = try? await ContactStore.shared.fetchCount() {
                                totalCount = max(count, backups.count)
                            }
                            progressedCount = backups.count
                            mode = .convertOne
                            operationState = .completed
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerBar: some View {
        HStack(spacing: 12) {
            if let icon = Bundle.main.appIcon {
                Image(uiImage: icon)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            Text("MAIN_APP_TITLE")
                .font(.title3.bold())
            Spacer()
            Button {
                contactPickerMode = .previewOne
                isShowingContactPicker = true
            } label: {
                Text("MAIN_PREVIEW")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
            }
            .foregroundStyle(.primary)
        }
    }

    private var convertAllButton: some View {
        Button {
            if isRunning {
                operationState = .stopped
            } else {
                showConvertConfirm = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isRunning ? "stop.fill" : "arrow.2.squarepath")
                    .font(.body.weight(.semibold))
                Text(isRunning ? NSLocalizedString("STOP", comment: "") : NSLocalizedString("MAIN_CONVERT", comment: ""))
                    .font(.title3.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                LinearGradient(
                    colors: isRunning
                        ? [Color(red: 1.0, green: 0.22, blue: 0.22), Color(red: 0.85, green: 0.10, blue: 0.10)]
                        : [Color.appOrange, Color(red: 1.0, green: 0.45, blue: 0.0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(
                color: (isRunning ? Color.red : Color.appOrange).opacity(0.35),
                radius: 12,
                y: 6
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isRunning)
    }

    private var actionsCard: some View {
        VStack(spacing: 0) {
            Button {
                contactPickerMode = .convertOne
                isShowingContactPicker = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(LinearGradient(
                                colors: [Color.appOrange, Color(red: 1.0, green: 0.45, blue: 0.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 32, height: 32)
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Text("MAIN_CONVERT_ONE")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
            }
            .disabled(isRunning)

            Divider()
                .padding(.leading, 62)

            NavigationLink(destination: SettingsScreen()) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(.systemGray))
                            .frame(width: 32, height: 32)
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Text("SETTINGS_TITLE")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                if isRunning && mode == .restoreAll {
                    operationState = .stopped
                } else {
                    Task { await startRestore() }
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title3)
                    Text("MAIN_RESTORE")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color.appTeal)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.appTeal.opacity(0.12))
                )
            }
            .disabled(isRunning && mode != .restoreAll)

            Button {
                if isRunning && mode == .clearAll {
                    operationState = .stopped
                } else {
                    Task { await startClearPhotos() }
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.title3)
                    Text("MAIN_CLEAR_PHOTOS")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color(.secondaryLabel))
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
            .disabled(isRunning && mode != .clearAll)
        }
    }

    // MARK: - Ad Helper

    private func presentFullAdThen(_ action: @escaping @Sendable () async -> Void) {
        guard launchCount > 1 else {
            Task { await action() }
            return
        }
        Task {
            await adManager.requestAppTrackingIfNeed()
            await adManager.show(unit: .full)
            await action()
        }
    }

    // MARK: - Operations

    private func startConvertAll() async {
        guard let service = contactService else { return }
        Analytics.logLeesamEvent(.startConvertAll)
        mode = .convertAll
        operationState = .running
        progressedCount = 0
        totalCount = 0
        do {
            try await service.convertAll(
                onProgress: { done, total in
                    progressedCount = done
                    totalCount = total
                },
                isCancelled: { self.operationState == .stopped }
            )
            Analytics.logLeesamEvent(.finishConvertAll)
            operationState = .completed
            progressedCount = backups.count
        } catch {
            operationState = .ready
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func startRestore() async {
        guard backups.count > 0 else {
            errorMessage = NSLocalizedString("ERR_NO_BAK_CONTACTS", comment: "")
            showError = true
            return
        }
        showRestoreConfirm = true
    }

    private func runRestore() async {
        guard let service = contactService else { return }
        Analytics.logLeesamEvent(.startRestore)
        mode = .restoreAll
        operationState = .running
        let initialCount = backups.count
        progressedCount = initialCount
        do {
            try await service.restoreAll(
                onProgress: { done, _ in
                    progressedCount = initialCount - done
                },
                isCancelled: { self.operationState == .stopped }
            )
            Analytics.logLeesamEvent(.finishRestore)
            operationState = .completed
            progressedCount = 0
        } catch {
            operationState = .ready
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func startClearPhotos() async {
        showClearConfirm = true
    }

    private func runClearPhotos() async {
        guard let service = contactService else { return }
        Analytics.logLeesamEvent(.startClear)
        mode = .clearAll
        operationState = .running
        progressedCount = 0
        totalCount = 0
        do {
            try await service.clearAllPhotos(
                onProgress: { done, total in
                    progressedCount = done
                    totalCount = total
                },
                isCancelled: { self.operationState == .stopped }
            )
            Analytics.logLeesamEvent(.finishClear)
            operationState = .completed
        } catch {
            operationState = .ready
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Ring Progress View

private struct RingProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemFill), lineWidth: 20)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color.appRingStart, Color.appRingEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)

            Circle()
                .fill(Color(.systemGroupedBackground))
                .padding(11)
        }
    }
}

// MARK: - Bundle + App Icon

private extension Bundle {
    var appIcon: UIImage? {
        guard
            let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let files = primary["CFBundleIconFiles"] as? [String],
            let name = files.last
        else { return nil }
        return UIImage(named: name)
    }
}

// MARK: - App Colors

extension Color {
    static let appOrange = Color(red: 1.0, green: 0.72, blue: 0.0)
    static let appTeal = Color(red: 0.13, green: 0.70, blue: 0.67)
    static let appRingStart = Color(red: 0.10, green: 0.35, blue: 0.85)
    static let appRingEnd = Color(red: 0.40, green: 0.65, blue: 1.0)
}
