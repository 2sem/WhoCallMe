import SwiftUI
import Contacts

struct ContactTemplateView: UIViewControllerRepresentable {
    let contact: CNContact
    let originalImage: UIImage?
    var isPreviewMode: Bool = false

    func makeUIViewController(context: Context) -> ContactTemplateViewController {
        UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ContactTemplateViewController")
            as! ContactTemplateViewController
    }

    func updateUIViewController(_ vc: ContactTemplateViewController, context: Context) {
        vc.isPreviewMode = isPreviewMode
        vc.useThumbNail = !LSDefaults.needFullscreenPhoto
        vc.contact = contact
        vc.originalImage = originalImage
        vc.showAllInfos()
        vc.refresh()
    }
}
