import UIKit
import Contacts
import SwiftUI

@MainActor
struct ContactImageRenderer {
    static func render(contact: CNContact, originalImage: UIImage?) -> UIImage? {
        guard LSDefaults.needMakeIncomingPhoto else { return nil }

        let size = CGSize(width: 375, height: 667)

        let content = ContactTemplateView(
            contact: contact,
            originalImage: originalImage,
            generatedImageData: nil,
            isPreviewMode: false
        )
        .ignoresSafeArea()
        .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = ProposedViewSize(size)
        renderer.scale = UIScreen.main.scale

        return renderer.uiImage
    }
}
