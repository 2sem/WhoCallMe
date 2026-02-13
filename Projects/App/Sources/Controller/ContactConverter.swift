import Contacts
import LSExtensions

// Pure conversion logic extracted from MainViewController
struct ContactConverter {
    static let searchTag = "WhoCallMe"

    // MARK: - Generate Index (adds cho-seong, nickname, suffix)

    static func generateIndex(_ contact: CNMutableContact, backup: ContactBackup?) {
        // Preserve original suffix if it was changed since last convert
        if (backup?.generatedSuffix ?? "") != contact.nameSuffix {
            backup?.suffix = contact.nameSuffix
        }
        contact.nameSuffix = backup?.suffix ?? ""

        // Preserve original nickname if it was changed since last convert
        if LSDefaults.needGenerateNickname && (backup?.generatedNickname ?? "") != contact.nickname {
            backup?.nickname = contact.nickname
        }

        let fullDesc = contact.fullName ?? ""
        var jobDesc = ""

        if LSDefaults.needContainsOrg && !contact.organizationName.isEmpty {
            jobDesc += contact.organizationName
        }
        if LSDefaults.needContainsDept && !contact.departmentName.isEmpty {
            jobDesc += (jobDesc.isEmpty || jobDesc.last == "/" ? "" : "/") + contact.departmentName
        }
        if LSDefaults.needContainsJob && !contact.jobTitle.isEmpty {
            jobDesc += (jobDesc.isEmpty || jobDesc.last == "/" ? "" : "/") + contact.jobTitle
        }

        // Set generated suffix from org/dept/job
        if contact.nameSuffix.isEmpty && !jobDesc.isEmpty {
            backup?.generatedSuffix = jobDesc
            contact.nameSuffix = jobDesc
        }

        // Set generated nickname from full name + job description
        if LSDefaults.needGenerateNickname,
           (backup?.nickname ?? "").isEmpty,
           !fullDesc.trimmingCharacters(in: .whitespaces).isEmpty || !jobDesc.trimmingCharacters(in: .whitespaces).isEmpty {
            let spacer = fullDesc.isEmpty ? "" : " "
            backup?.generatedNickname = "\(fullDesc)\(spacer)\(jobDesc)"
            contact.nickname = backup?.generatedNickname ?? ""
        }

        // Insert cho-seong into note
        guard LSDefaults.needMakeChoseong else { return }
        let choSeongs = (fullDesc + jobDesc).getKoreanChoSeongs() ?? ""
        guard !choSeongs.isEmpty else { return }

        let note = contact.note
        let range = note.range(byTag: searchTag)

        let high: String
        let low: String
        let highGap: String
        let lowGap: String

        if let range {
            high = String(note[..<range.lowerBound])
            low = String(note[range.upperBound...])
            highGap = ""
            lowGap = ""
        } else {
            high = note
            low = ""
            highGap = note.isEmpty ? "" : "\n"
            lowGap = ""
        }

        contact.note = "\(high)\(highGap)\(choSeongs.wrap(byTag: searchTag))\(lowGap)\(low)"
    }

    // MARK: - Restore Index (removes cho-seong, reverts suffix and nickname)

    static func restoreIndex(_ contact: CNMutableContact, backup: ContactBackup?) {
        guard backup != nil else { return }

        // Restore suffix
        if backup?.generatedSuffix != contact.nameSuffix {
            backup?.generatedSuffix = contact.nameSuffix
        } else {
            contact.nameSuffix = backup?.suffix ?? ""
        }

        // Restore nickname
        if backup?.generatedNickname != contact.nickname {
            backup?.generatedNickname = contact.nickname
        } else {
            contact.nickname = backup?.nickname ?? ""
        }

        // Remove WhoCallMe tag from note
        let note = contact.note
        if let range = note.range(byTag: searchTag) {
            contact.note = String(note[..<range.lowerBound]) + String(note[range.upperBound...])
        }
    }
}

// MARK: - CNContact helpers

extension CNContact {
    var fullName: String? {
        let name = CNContactFormatter.string(from: self, style: .fullName)
        return name?.isEmpty == false ? name : nil
    }
}
