import SwiftUI
import Contacts
import FirebaseAnalytics

struct PreviewScreen: View {
    let contact: CNContact
    let originalImage: UIImage?
    let generatedImageData: Data?

    var body: some View {
        ContactTemplateView(
            contact: contact,
            originalImage: originalImage,
            generatedImageData: generatedImageData,
            isPreviewMode: true
        )
        .ignoresSafeArea()
        .navigationTitle("MAIN_PREVIEW")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Analytics.logPreviewScreen()
        }
    }
}
