//
//  WCDefaults.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2017. 2. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import StringLogger

class LSDefaults{
    private static var isInitialized = false;
    static var Defaults : UserDefaults{
        get{
            if !self.isInitialized{
                UserDefaults.standard.register(defaults: [Keys.needGenerateNickname : true,
                                                          Keys.needContainsOrg : true,
                                                          Keys.needContainsDept : true,
                                                          Keys.needContainsJob : true,
                                                          Keys.needMakeChoseong : true,
                                                          Keys.needMakeIncomingPhoto : true,
                                                          
                                                          Keys.needFullscreenPhoto : false,
                                                          Keys.needPhotoContainsOrg : true,
                                                          Keys.needPhotoContainsDept : true,
                                                          Keys.needPhotoContainsJob : true])
                self.isInitialized = true;
            }
            
            return UserDefaults.standard;
        }
    }
    
    class Keys{
        static let IsUpsideDown = "IsUpsideDown";
        static let IsRotateFixed = "IsRotateFixed";
        
        static let LastFullADShown = "LastFullADShown";
        static let LastOpeningAdPrepared = "LastOpeningAdPrepared";
        static let LastShareShown = "LastShareShown";
        static let LastRewardShown = "LastRewardShown";
        
        static let needMakeIncomingPhoto = "needMakeIncomingPhoto";
        static let needGenerateNickname = "needGenerateNickname";
        static let needContainsOrg = "needContainsOrg";
        static let needContainsDept = "needContainsDept";
        static let needContainsJob = "needContainsJob";
        static let needMakeChoseong = "needMakeChoseong";

        static let needFullscreenPhoto = "needFullscreenPhoto";
        static let needPhotoContainsDept = "needPhotoContainsDept";
        static let needPhotoContainsOrg = "needPhotoContainsOrg";
        static let needPhotoContainsJob = "needPhotoContainsJob";

        static let LaunchCount = "LaunchCount";
        
        static let AdsShownCount = "AdsShownCount";
        static let AdsTrackingRequested = "AdsTrackingRequested";
    }
    
    static var isUpsideDown : Bool?{
        get{
            return Defaults.bool(forKey: Keys.IsUpsideDown);
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.IsUpsideDown);
        }
    }
    
    static var isRotateFixed : Bool?{
        get{
            return Defaults.bool(forKey: Keys.IsRotateFixed);
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.IsRotateFixed);
        }
    }
    
    static var LastFullADShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastFullADShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastFullADShown);
        }
    }
    
    static var LastShareShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastShareShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastShareShown);
        }
    }
    
    static var LastRewardShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastRewardShown);
            return Date.init(timeIntervalSince1970: seconds);
        }

        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastRewardShown);
        }
    }

    static var LastOpeningAdPrepared: Date {
        get {
            let seconds = Defaults.double(forKey: Keys.LastOpeningAdPrepared)
            return Date(timeIntervalSince1970: seconds)
        }
        set {
            Defaults.set(newValue.timeIntervalSince1970, forKey: Keys.LastOpeningAdPrepared)
        }
    }
    
    static func increaseLaunchCount(){
        self.LaunchCount = self.LaunchCount.advanced(by: 1);
    }
    static var LaunchCount : Int{
        get{
            //UIApplication.shared.version
            return Defaults.integer(forKey: Keys.LaunchCount);
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.LaunchCount);
        }
    }
    
    //Options
    static var needMakeIncomingPhoto : Bool{
        get{
            return Defaults.bool(forKey: Keys.needMakeIncomingPhoto) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needMakeIncomingPhoto);
        }
    }
    
    static var needGenerateNickname : Bool{
        get{
            return Defaults.bool(forKey: Keys.needGenerateNickname) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needGenerateNickname);
        }
    }
    
    static var needContainsOrg : Bool{
        get{
            return Defaults.bool(forKey: Keys.needContainsOrg) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needContainsOrg);
        }
    }
    
    static var needContainsDept : Bool{
        get{
            return Defaults.bool(forKey: Keys.needContainsDept) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needContainsDept);
        }
    }
    
    static var needContainsJob : Bool{
        get{
            return Defaults.bool(forKey: Keys.needContainsJob) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needContainsJob);
        }
    }
    
    static var needMakeChoseong : Bool{
        get{
            return Defaults.bool(forKey: Keys.needMakeChoseong) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needMakeChoseong);
        }
    }
    
    static var needFullscreenPhoto : Bool{
        get{
            return Defaults.bool(forKey: Keys.needFullscreenPhoto) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needFullscreenPhoto);
        }
    }
    
    static var needPhotoContainsDept : Bool{
        get{
            return Defaults.bool(forKey: Keys.needPhotoContainsDept) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needPhotoContainsDept);
        }
    }
    
    static var needPhotoContainsOrg : Bool{
        get{
            return Defaults.bool(forKey: Keys.needPhotoContainsOrg) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needPhotoContainsOrg);
        }
    }
    
    static var needPhotoContainsJob : Bool{
        get{
            return Defaults.bool(forKey: Keys.needPhotoContainsJob) ;
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.needPhotoContainsJob);
        }
    }
}

extension LSDefaults{
    static var AdsShownCount : Int{
        get{
            return Defaults.integer(forKey: Keys.AdsShownCount);
        }
        
        set{
            Defaults.set(newValue, forKey: Keys.AdsShownCount);
        }
    }
    
    static func increateAdsShownCount(){
        guard AdsShownCount < 3 else {
            return
        }
        
        AdsShownCount += 1;
        "Ads Shown Count[\(AdsShownCount)]".debug();
    }
    
    static var AdsTrackingRequested : Bool{
        get{
            return Defaults.bool(forKey: Keys.AdsTrackingRequested);
        }
        
        set{
            Defaults.set(newValue, forKey: Keys.AdsTrackingRequested);
        }
    }
    
    static func requestAppTrackingIfNeed() -> Bool{
        guard !AdsTrackingRequested else{
            return false;
        }
        
        guard AdsShownCount >= 1 else{
            AdsShownCount += 1;
            return false;
        }
        
        guard #available(iOS 14.0, *) else{
            return false;
        }
        
        SwiftUIAdManager.shared?.requestPermission { _ in
            AdsTrackingRequested = true
        }
        
        return true;
    }
}

