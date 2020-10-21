//
//  Crashlytics+.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2020/10/21.
//  Copyright © 2020 leesam. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

extension Crashlytics{
//    func storeUserEnvironment(){
//        //self.setUserID("\(SWLoginManager.shared.userId ?? ""):\(SWLoginManager.shared.userName ?? ""):\(SWLoginManager.shared.uuid)");
//        self.setUserID("\(SWLoginManager.shared.userId ?? "unknown")");
//        //Crashlytics.crashlytics().setCustomValue(42, forKey: "MeaningOfLife")
//        self.recordValue(SWLoginManager.shared.userId, property: .userId);
//        //self.recordValue(SWLoginManager.shared.userName, property: .userName);
//        self.recordValue(SWLoginManager.shared.uuid, property: .uuid);
//        self.recordValue(UIDevice.current.localizedModel, property: .device);
//        self.recordValue(UIApplication.shared.carrier?.carrierName, property: .carrierName);
//        self.recordValue(UIApplication.shared.carrier?.mobileCountryCode, property: .mobileCountryCode);
//        self.recordValue(UIApplication.shared.carrier?.carrierName, property: .carrierName);
//        self.recordValue(UIApplication.shared.carrier?.isoCountryCode, property: .isoCountryCode);
//
//        Analytics.setUserProperty(SWLoginManager.shared.userId ?? "unknown", forName: "User");
//    }
//
//    func storeNetworkStatus(reachaility: Reachability){
//        Crashlytics.crashlytics().setCustomValue(reachaility.connection.description, forKey: "NetworkStatus");
//    }
//
//    func recordValue(_ value: Any?, property: SiwonCrashProperty){
//        guard let value = value else{
//            return;
//        }
//
//        Crashlytics.crashlytics().setCustomValue(value, forKey: property.rawValue);
//    }
    
//    func record(_ error: Error, userInfo: [String : Any]){
//        self.record(error: error);
//    }
}
