//
//  UIApplication+KakaoLink.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import KakaoSDKShare
import KakaoSDKTemplate
import LSExtensions

extension UIApplication{
    func shareByKakao(){
        let kakaoContent = Content.init(title: UIApplication.shared.displayName ?? "",
                                        description: "연락처 초성 검색이 안되시나요?", link: .init())
        
        let kakaoTemplate = FeedTemplate.init(content: kakaoContent,
                                              buttons: [.init(title: "다운로드",
                                                              link: .init())])
        
        ShareApi.shared.shareDefault(templatable: kakaoTemplate) { result, error in
            guard let result = result else {
                print("kakao error[\(error.debugDescription )]")
                return
            }
            
            UIApplication.shared.open(result.url)
            print("kakao warn[\(result.warningMsg?.debugDescription ?? "")] args[\(result.argumentMsg?.debugDescription ?? "")]")
        }
    }
}
