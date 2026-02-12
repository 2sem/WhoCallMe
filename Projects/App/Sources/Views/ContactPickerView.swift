import SwiftUI
import ContactsUI

struct ContactPickerView: UIViewControllerRepresentable {
    let onSelect: (CNContact?) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.displayedPropertyKeys = [
            CNContactGivenNameKey,
            CNContactNameSuffixKey,
            CNContactNicknameKey,
            CNContactImageDataKey,
            CNContactOrganizationNameKey,
            CNContactDepartmentNameKey,
            CNContactJobTitleKey,
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactNoteKey
        ]
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        let onSelect: (CNContact?) -> Void

        init(onSelect: @escaping (CNContact?) -> Void) {
            self.onSelect = onSelect
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(contact)
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            onSelect(nil)
        }
    }
}
