import UIKit
import Contacts

@MainActor
struct ContactImageRenderer {
    static func render(contact: CNContact, originalImage: UIImage?) -> UIImage? {
        guard LSDefaults.needMakeIncomingPhoto else { return nil }

        guard let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ContactTemplateViewController")
            as? ContactTemplateViewController
        else { return nil }

        let frame = CGRect(x: 0, y: 0, width: 375, height: 667)
        let window = UIWindow(frame: frame)
        window.rootViewController = vc
        window.makeKeyAndVisible()

        vc.isPreviewMode = false
        vc.useThumbNail = !LSDefaults.needFullscreenPhoto
        vc.contact = contact
        vc.originalImage = originalImage
        vc.showAllInfos()
        vc.refresh()
        if !LSDefaults.needFullscreenPhoto {
            vc.showInfo(.photo, visible: false)
        }
        vc.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(bounds: vc.view.bounds)
        let image = renderer.image { ctx in
            vc.view.layer.render(in: ctx.cgContext)
        }

        window.isHidden = true
        return image
    }
}
