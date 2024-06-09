//
//  WCMMessageManager.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 3. 19..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

class WCMMessageManager: NSObject {
    enum MassageName : String{
        case STATUS_PROCESSED = "STATUS_PROCESSED"
        case STATUS_BAK_DATA = "STATUS_BAK_DATA"
        case STATUS_FIND_BAK_DATA = "STATUS_FIND_BAK_DATA"
        case STATUS_CHECK_BAK_DATA = "STATUS_CHECK_BAK_DATA"
        case STATUS_CREATE_IMAGE = "STATUS_CREATE_IMAGE"
        case STATUS_CREATE_INDEX = "STATUS_CREATE_INDEX";
        case STATUS_SAVE_CONTACT = "STATUS_SAVE_CONTACT"
        case STATUS_SAVE_DATA = "STATUS_SAVE_DATA"

        case STATUS_CONVERTING = "STATUS_CONVERTING"
        case STATUS_CONVERTED = "STATUS_CONVERTED"
        
        case STATUS_RESTORING = "STATUS_RESTORING"
        case STATUS_RESTORED = "STATUS_RESTORED"
        
        case STATUS_CLEARING = "STATUS_CLEARING"
        case STATUS_CLEARED = "STATUS_CLEARED"
        
        case STATUS_STOPPED = "STATUS_STOPPED"
        
        case WARN="WARN"

        case WARN_CLEAR_PHOTOS_MSG="WARN_CLEAR_PHOTOS_MSG"
        case WARN_CLEAR_PHOTOS_CLEAR="WARN_CLEAR_PHOTOS_CLEAR"

        case WARN_RESTORE_CONTACTS_MSG="WARN_RESTORE_CONTACTS_MSG"
        case WARN_RESTORE_CONTACTS_RESTORE="WARN_RESTORE_CONTACTS_RESTORE"

        case ERR_NO_BAK_CONTACTS="ERR_NO_BAK_CONTACTS"
        
        case CANCEL = "CANCEL"
        
        case ERROR = "ERROR"
        
        case OK = "OK"
        
        case STOP = "STOP"
        
        case MSG_PLEASE_ALLOW_APP_CONTACTS="MSG_PLEASE_ALLOW_APP_CONTACTS"
        
        case SETTINGS = "SETTINGS"
    }
    
    subscript(name : WCMMessageManager.MassageName) -> String{
        get{
            /*
            case Ready = 0
            case BackupOriginal = 1
            case FindOriginal = 2
            case CheckOriginal = 3
            case CreateImage = 4
            case CreateIndex = 5
            case SaveContact = 6
            case SaveData = 7
            
            case Photo = 0
            case Organization = 1
            case Department = 2
            case JobTitle = 3
            */
            return NSLocalizedString(name.rawValue, comment: "");
        }
    }
    
    func getMsg(_ name : WCMMessageManager.MassageName) -> String{
        return NSLocalizedString(name.rawValue, comment: "");
    }
}
