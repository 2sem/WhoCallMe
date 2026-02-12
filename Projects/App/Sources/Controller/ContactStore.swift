import Contacts
import FirebaseCrashlytics

// Async/await wrapper replacing RxContactController
actor ContactStore {
    static let shared = ContactStore()
    private let store = CNContactStore()

    static let keysForConvert: [CNKeyDescriptor] = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactNameSuffixKey as CNKeyDescriptor,
        CNContactDepartmentNameKey as CNKeyDescriptor,
        CNContactJobTitleKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactImageDataKey as CNKeyDescriptor,
        CNContactNoteKey as CNKeyDescriptor,
        CNContactNicknameKey as CNKeyDescriptor,
        CNContactOrganizationNameKey as CNKeyDescriptor,
    ]

    static let keysForClear: [CNKeyDescriptor] = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactImageDataKey as CNKeyDescriptor,
    ]

    func requestAccess() async throws {
        let granted = try await store.requestAccess(for: .contacts)
        guard granted else {
            throw ContactError.permissionDenied
        }
    }

    func fetchAll(keys: [CNKeyDescriptor]) async throws -> [CNContact] {
        let id = store.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: id)
        return try store.unifiedContacts(matching: predicate, keysToFetch: keys)
    }

    func fetch(identifiers: [String], keys: [CNKeyDescriptor]) async throws -> [CNContact] {
        let predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)
        return try store.unifiedContacts(matching: predicate, keysToFetch: keys)
    }

    func save(_ contact: CNMutableContact) async throws {
        let req = CNSaveRequest()
        req.update(contact)
        do {
            try store.execute(req)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            throw error
        }
    }
}

enum ContactError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString("MSG_PLEASE_ALLOW_APP_CONTACTS", comment: "")
        }
    }
}
