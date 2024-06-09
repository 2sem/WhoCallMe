//
//  OriginalContract+CoreDataProperties.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 3. 14..
//  Copyright © 2016년 leesam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension OriginalContract {

    @NSManaged var id: String?
    @NSManaged var imageData: Data?
    @NSManaged var storedDate: Date?
    @NSManaged var generatedImage: Data?
    @NSManaged var nickname: String?
    @NSManaged var generatedNickname: String?
    @NSManaged var suffix: String?
    @NSManaged var generatedSuffix: String?
}
