//
//  GADInterstialManager.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 4. 12..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol GADInterstialManagerDelegate : NSObjectProtocol{
    func GADInterstialGetLastShowTime() -> Date;
    func GADInterstialUpdate(showTime : Date);
    func GADInterstialWillLoad();
}

extension GADInterstialManagerDelegate{
    func GADInterstialWillLoad(){
        
    }
}

class GADInterstialManager : NSObject{
    var window : UIWindow;
    var unitId : String;
    var interval : TimeInterval = 60.0 * 60.0 * 3.0;
    var canShowFirstTime = true;
    var delegate : GADInterstialManagerDelegate?;
    
    fileprivate static var _shared : GADInterstialManager?;
    static var shared : GADInterstialManager?{
        get{
            return _shared;
        }
    }
    
    init(_ window : UIWindow, unitId : String, interval : TimeInterval = 60.0 * 60.0 * 3.0) {
        self.window = window;
        self.unitId = unitId;
        self.interval = interval;
        
        super.init();
        //self.reset();
        if GADInterstialManager._shared == nil{
            GADInterstialManager._shared = self;
        }
    }
    
    func reset(){
        //RSDefaults.LastFullADShown = Date();
        self.delegate?.GADInterstialUpdate(showTime: Date());
    }
    
    var fullAd : GADInterstitialAd?
    var canShow : Bool{
        get{
            var value = true;
            let now = Date();
            
            guard self.delegate != nil else {
                return value;
            }
            
            let lastShowTime = self.delegate!.GADInterstialGetLastShowTime();
            let time_1970 = Date.init(timeIntervalSince1970: 0);
            
            //(!self.canShowFirstTime &&
            guard self.canShowFirstTime || lastShowTime > time_1970 else{
                if lastShowTime <= time_1970{
                    self.delegate?.GADInterstialUpdate(showTime: now);
                }
                value = false;
                return value;
            }
            
            let spent = now.timeIntervalSince(lastShowTime);
            value = spent > self.interval;
            print("time spent \(spent) since \(lastShowTime). now[\(now)]");
            
            return value;
        }
    }
    
    func show(_ force : Bool = false){
        guard self.canShow || force else {
            //self.window.rootViewController?.showAlert(title: "알림", msg: "1시간에 한번만 후원하실 수 있습니다 ^^;", actions: [UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
            return;
        }
        
        self._show();
    }
    
    func _show(){
        /*guard self.canShow else {
         return;
         }*/
        
        guard self.fullAd?.isReady() ?? true else{
            print("full ad is not ready - self.fullAd?.isReady");
            self.__show();
            return;
        }
        
        print("create new full ad");
        
        let req = GADRequest();
        
        GADInterstitialAd.load(withAdUnitID: self.unitId, request: req, completionHandler: { (newAd, error) in
            self.fullAd = newAd;
            self.fullAd?.fullScreenContentDelegate = self;
            self._show();
        })
        self.delegate?.GADInterstialWillLoad();
    }
    
    private func __show(){
        guard self.window.rootViewController != nil else{
            return;
        }
        
        /*guard self.canShow else {
         return;
         }*/
        
        //ignore if alert is being presented
        /*if let alert = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? UIAlertController{
         alert.dismiss(animated: false, completion: nil);
         }*/
        
        guard !(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is UIAlertController) else{
            //alert.dismiss(animated: false, completion: nil);
            self.fullAd = nil;
            return;
        }
        
        print("present full ad view[\(self.window.rootViewController?.description ?? "")]");
        self.fullAd?.present(fromRootViewController: self.window.rootViewController!);
        self.delegate?.GADInterstialUpdate(showTime: Date());
        //RSDefaults.LastFullADShown = Date();
    }
}

extension GADInterstialManager : GADFullScreenContentDelegate{
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.fullAd = nil;
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        /*self.window.rootViewController?.showAlert(title: "후원해주셔서 감사합니다.", msg: "불편하신 사항은 리뷰에 남겨주시면 반영하겠습니다.", actions: [UIAlertAction.init(title: "확인", style: .default, handler: nil), UIAlertAction.init(title: "평가하기", style: .default, handler: { (act) in
        //            UIApplication.shared.openReview();
        //        })], style: .alert);*/
    }
//    func interstitialDidReceiveAd(_ ad: GADInterstitialAd) {
//        print("Interstitial is ready to be presented");
//
//        self._show();
//    }
}
