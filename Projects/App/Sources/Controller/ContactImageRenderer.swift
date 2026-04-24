import UIKit
import Contacts
import SwiftUI

@MainActor
struct ContactImageRenderer {
    static func render(contact: CNContact, originalImage: UIImage?) -> UIImage? {
        guard LSDefaults.needMakeIncomingPhoto else { return nil }

        let size = CGSize(width: 375, height: 667)

        let view = ContactTemplateView(
            contact: contact,
            originalImage: originalImage,
            generatedImageData: nil,
            isPreviewMode: false
        )
        .ignoresSafeArea()

        let host = UIHostingController(rootView: view)
        host.view.frame = CGRect(origin: .zero, size: size)
        host.view.backgroundColor = .clear

        let window = UIWindow(frame: host.view.bounds)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            window.windowScene = scene
        }
        window.rootViewController = host
        window.makeKeyAndVisible()

        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            host.view.layer.render(in: ctx.cgContext)
        }

        window.isHidden = true
        return image
    }
}
