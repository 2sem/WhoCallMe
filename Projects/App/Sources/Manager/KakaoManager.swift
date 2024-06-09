//
//  KakaoManager.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2023/06/14.
//  Copyright © 2023 leesam. All rights reserved.
//

import Foundation
import KakaoSDKCommon


class KakaoManager {
    static func initialize() {
        let keyName = "KAKAO_APP_KEY"
        
        guard let plistDict = Bundle.main.infoDictionary else{
            preconditionFailure("Please create plist file named of Where We Go. info.plist");
        }
        
        guard let key = plistDict[keyName] as? String else {
            preconditionFailure("Please insert \(keyName) into info.plist.");
        }
        
        KakaoSDK.initSDK(appKey: key)
    }
}
