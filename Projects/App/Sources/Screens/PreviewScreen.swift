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
        .navigationTitle("미리보기")
        .navigationBarTitleDisplayMode(.inline)
    }
}
