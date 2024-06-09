//
//  Analytics+.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2019. 6. 29..
//  Copyright © 2019년 leesam. All rights reserved.
//

import UIKit
import FirebaseAnalytics

extension UIViewController{
    func setAnalyticScreenName(){
        Analytics.setScreenName(for: self);
    }
}

extension Analytics{
    static func setScreenName(for viewController: UIViewController){
        var name : String?;
        let className : String? = viewController.classForCoder.description().components(separatedBy: ".").last;
        
        if viewController is MainViewController{
            name = "메인화면";
        }else if viewController is ContactTemplateViewController{
            name = "미리보기";
        }
        
        var params : [String : Any] = [AnalyticsParameterScreenClass : type(of: self)];
        
        if let name = name{
            params[AnalyticsParameterScreenName] = name;
        }
        
        FirebaseAnalytics.Analytics.logEvent(AnalyticsEventScreenView,
                                             parameters: params);
        print("[\(#function)] set screen name for firebase analytics. name[\(name ?? "")] screen[\(className ?? "")]");
    }
    
    enum LeesamEvent : String{
        case previewCall = "수신화면 미리보기"
        case startConvertAll = "전체변환시작"
        case finishConvertAll = "전체변환완료"
        //case pickContact = "연락처 선택"
        case convertOne = "하나만변환"
        case startRestore = "복원시작"
        case finishRestore = "복원완료"
        case startClear = "사진삭제시작"
        case finishClear = "사진삭제완료"
    }
    
    class LeesamEventProperty{
        static let autoPlay = "자동재생"
        static let course = "강좌번호"
        static let lecture = "강의번호"
        static let lectureTitle = "강의제목"
        static let lectureUrl = "강의파일"
        static let speed = "재생속도"
    }
    
    /*static func logSiwonEvent(_ event: SiwonEvent, parameters: [String : Any]? = nil){
     self.logEvent(event.rawValue, parameters: parameters);
     }*/
    
    static func logLeesamEvent(_ event: LeesamEvent, parameters: [String : Any] = [:]){
        let params : [String : Any] = [:];
        /*if let lecture = lecture{
         params[SiwonEventProperty.course] = lecture.course?.no ?? lecture.courseNo;
         params[SiwonEventProperty.lecture] = lecture.no;
         params[SiwonEventProperty.lectureTitle] = lecture.title;
         params[SiwonEventProperty.lectureUrl] = lecture.media?.absoluteString;
         }*/
        /*params.merge(parameters){ (left, right) in right }
         if let autoPlay = autoPlay{
         params[SiwonEventProperty.autoPlay] = autoPlay.description;
         }*/
        
        self.logEvent(event.rawValue, parameters: params);
    }
}
