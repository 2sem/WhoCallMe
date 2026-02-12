import SwiftUI
import SwiftData
import Contacts

struct MainScreen: View {
    // MARK: - State (mirrors MainViewController BehaviorSubjects)

    enum Mode {
        case convertAll, convertOne, restoreAll, previewOne, clearAll
    }

    enum OperationState {
        case ready, running, stopped, completed
    }

    @State private var mode: Mode = .convertAll
    @State private var operationState: OperationState = .ready
    @State private var progressedCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var useFullscreenPhoto: Bool = LSDefaults.needFullscreenPhoto

    @State private var isShowingContactPicker = false
    @State private var contactPickerMode: Mode = .convertOne

    @Environment(\.modelContext) private var modelContext
    @Query private var backups: [ContactBackup]

    // MARK: - Computed

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

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Template preview placeholder (Step 6: wrap ContactTemplateViewController)
            templatePreviewArea

            Divider()

            // Progress + status
            progressArea
                .padding(.vertical, 12)

            Divider()

            // Photo option toggle
            photoOptionRow
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()

            // Action buttons
            actionButtons
                .padding(16)

            Spacer()

            // AdMob banner placeholder (Step 8)
            bannerPlaceholder
        }
        .onAppear {
            totalCount = backups.count
            progressedCount = backups.count
        }
        .sheet(isPresented: $isShowingContactPicker) {
            ContactPickerView { contact in
                isShowingContactPicker = false
                guard let contact else { return }
                if contactPickerMode == .previewOne {
                    // Step 6: preview(contact)
                } else {
                    // Step 6: convert(contact)
                }
            }
        }
    }

    // MARK: - Subviews

    private var templatePreviewArea: some View {
        // Step 6: replace with UIViewControllerRepresentable for ContactTemplateViewController
        Rectangle()
            .fill(Color(.systemGray6))
            .frame(height: 180)
            .overlay(Text("Preview").foregroundStyle(.secondary))
    }

    private var progressArea: some View {
        HStack(spacing: 20) {
            CircularProgressView(progress: progress)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(progressedCount)")
                    .font(.title2.monospacedDigit())
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var photoOptionRow: some View {
        Toggle(isOn: $useFullscreenPhoto) {
            Text(NSLocalizedString("option_fullscreen_photo", comment: "Fullscreen Photo"))
        }
        .onChange(of: useFullscreenPhoto) { _, newValue in
            LSDefaults.needFullscreenPhoto = newValue
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                // Convert All / Stop
                Button {
                    if isRunning {
                        operationState = .stopped
                    } else {
                        Task { await startConvertAll() }
                    }
                } label: {
                    Label(isRunning ? NSLocalizedString("STOP", comment: "") : NSLocalizedString("convert_all", comment: "Convert All"),
                          systemImage: isRunning ? "stop.fill" : "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isRunning && operationState == .running)

                // Convert One
                Button {
                    contactPickerMode = .convertOne
                    isShowingContactPicker = true
                } label: {
                    Label(NSLocalizedString("convert_one", comment: "Convert One"), systemImage: "person.crop.circle.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isRunning)
            }

            HStack(spacing: 10) {
                // Preview
                Button {
                    contactPickerMode = .previewOne
                    isShowingContactPicker = true
                } label: {
                    Label(NSLocalizedString("preview", comment: "Preview"), systemImage: "eye")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isRunning)

                // Restore
                Button {
                    if isRunning {
                        operationState = .stopped
                    } else {
                        Task { await startRestore() }
                    }
                } label: {
                    Label(isRunning && mode == .restoreAll ? NSLocalizedString("STOP", comment: "") : NSLocalizedString("WARN_RESTORE_CONTACTS_RESTORE", comment: ""),
                          systemImage: "arrow.uturn.backward")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isRunning && mode != .restoreAll)
            }

            // Clear Photos
            Button {
                if isRunning {
                    operationState = .stopped
                } else {
                    Task { await startClearPhotos() }
                }
            } label: {
                Label(isRunning && mode == .clearAll ? NSLocalizedString("STOP", comment: "") : NSLocalizedString("WARN_CLEAR_PHOTOS_CLEAR", comment: ""),
                      systemImage: "photo.slash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .disabled(isRunning && mode != .clearAll)
        }
    }

    private var bannerPlaceholder: some View {
        // Step 8: replace with GADBannerView UIViewRepresentable
        Color.clear.frame(height: 0)
    }

    // MARK: - Operations (Step 6: implement full logic)

    private func startConvertAll() async {
        // Step 6
    }

    private func startRestore() async {
        // Step 6
    }

    private func startClearPhotos() async {
        // Step 6
    }
}

// MARK: - Circular Progress (replaces LSCircleProgressView)

private struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}
