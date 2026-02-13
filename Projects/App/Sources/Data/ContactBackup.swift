import SwiftData
import Foundation

@Model
final class ContactBackup {
    var id: String
    var imageData: Data?
    var storedDate: Date
    var generatedImage: Data?
    var nickname: String?
    var generatedNickname: String?
    var suffix: String?
    var generatedSuffix: String?

    init(id: String, storedDate: Date = Date()) {
        self.id = id
        self.storedDate = storedDate
    }
}
