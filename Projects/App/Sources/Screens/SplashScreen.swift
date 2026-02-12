import SwiftUI
import SwiftData

struct SplashScreen: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var initializer = AppInitializer()

    var body: some View {
        Group {
            if initializer.isReady {
                MainScreen()
            } else {
                ProgressView()
            }
        }
        .task {
            await initializer.initialize(context: modelContext)
        }
    }
}
