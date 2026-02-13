import SwiftUI
import Contacts

struct PreviewScreen: View {
    let contact: CNContact

    var body: some View {
        ContactTemplateView(
            contact: contact,
            originalImage: nil,
            isPreviewMode: true
        )
        .ignoresSafeArea()
        .navigationTitle("MAIN_PREVIEW")
        .navigationBarTitleDisplayMode(.inline)
    }
}
