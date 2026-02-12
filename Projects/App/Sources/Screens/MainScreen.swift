import SwiftUI
import SwiftData
import Contacts

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

    var isRunning: Bool { operationState == .running }

    var progress: Double {
        guard totalCount > 0 else { return 1.0 }
        let p = mode == .restoreAll ? totalCount - progressedCount : progressedCount
        return Double(max(0, p)) / Double(totalCount)
    }

    var statusText: String {
        switch operationState {
        case .ready: return ""
        case .stopped: return NSLocalizedString("STATUS_STOPPED", comment: "")
        case .running, .completed:
            switch mode {
            case .convertAll:
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
            CheckeredBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground).opacity(0.85))

                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        RingProgressView(progress: progress)
                            .frame(width: 240, height: 240)

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
                }

                Spacer()

                VStack(spacing: 12) {
                    convertOneButton
                    settingsButton
                }
                .padding(.horizontal, 30)

                Spacer()

                bottomBar
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $previewContact) { contact in
            PreviewScreen(contact: contact)
        }
        .onAppear {
            contactService = ContactService(modelContext: modelContext)
            totalCount = backups.count
            progressedCount = backups.count
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
        .sheet(isPresented: $isShowingContactPicker) {
            ContactPickerView { contact in
                isShowingContactPicker = false
                guard let contact else { return }
                if contactPickerMode == .previewOne {
                    previewContact = contact
                } else {
                    Task {
                        do {
                            try await contactService?.convertOne(contact)
                            progressedCount = backups.count
                            totalCount = backups.count
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
        HStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("누군지 다알아")
                .font(.headline)
            Spacer()
            Button {
                contactPickerMode = .previewOne
                isShowingContactPicker = true
            } label: {
                Text("미리보기")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
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
                presentFullAdThen { await startConvertAll() }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isRunning ? "stop.fill" : "arrow.2.squarepath")
                    .font(.body.weight(.semibold))
                Text(isRunning ? NSLocalizedString("STOP", comment: "") : "변환")
                    .font(.title3.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(width: 200, height: 48)
            .background(Color.appOrange)
            .clipShape(Capsule())
            .shadow(color: .appOrange.opacity(0.4), radius: 8, y: 4)
        }
    }

    private var convertOneButton: some View {
        Button {
            contactPickerMode = .convertOne
            isShowingContactPicker = true
        } label: {
            HStack {
                Image(systemName: "arrow.2.squarepath")
                Text("선택한 연락처 변환")
                    .font(.body.weight(.semibold))
                Spacer()
                if backups.count > 0 {
                    Text("\(backups.count)")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.3))
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.appOrange)
            .clipShape(Capsule())
        }
        .disabled(isRunning)
    }

    private var settingsButton: some View {
        NavigationLink(destination: SettingsScreen()) {
            HStack {
                Image(systemName: "gearshape.fill")
                Text("설정")
                    .font(.body.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.appOrange)
            .clipShape(Capsule())
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 1) {
            Button {
                if isRunning && mode == .restoreAll {
                    operationState = .stopped
                } else {
                    Task { await startRestore() }   // shows confirm dialog
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title3)
                    Text("연락처 복원")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(Color.appTeal)
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
                    Text("모든 사진 삭제")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(Color(.darkGray))
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
            operationState = .completed
            totalCount = backups.count
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
        mode = .restoreAll
        operationState = .running
        progressedCount = backups.count
        totalCount = backups.count
        do {
            try await service.restoreAll(
                onProgress: { done, _ in
                    progressedCount = backups.count - done
                },
                isCancelled: { self.operationState == .stopped }
            )
            operationState = .completed
            progressedCount = 0
            totalCount = 0
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
                .stroke(Color(.systemGray5), lineWidth: 18)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color.appRingStart, Color.appRingEnd],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)

            Circle()
                .fill(Color(.systemBackground))
                .padding(10)
        }
    }
}

// MARK: - Checkered Background

private struct CheckeredBackground: View {
    private let tileSize: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let cols = Int(geo.size.width / tileSize) + 2
            let rows = Int(geo.size.height / tileSize) + 2

            Canvas { context, _ in
                for row in 0..<rows {
                    for col in 0..<cols {
                        let isLight = (row + col) % 2 == 0
                        let rect = CGRect(
                            x: CGFloat(col) * tileSize,
                            y: CGFloat(row) * tileSize,
                            width: tileSize,
                            height: tileSize
                        )
                        context.fill(
                            Path(rect),
                            with: .color(isLight ? Color(.systemGray6) : Color(.systemGray5))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - App Colors

extension Color {
    static let appOrange = Color(red: 1.0, green: 0.72, blue: 0.0)
    static let appTeal = Color(red: 0.13, green: 0.70, blue: 0.67)
    static let appRingStart = Color(red: 0.10, green: 0.35, blue: 0.85)
    static let appRingEnd = Color(red: 0.40, green: 0.65, blue: 1.0)
}
