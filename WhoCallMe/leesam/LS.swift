//
//  LS.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 3. 16..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

class LS: NSObject {
    static func async(_ block: @escaping ()->()){
        let queue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

//        DISPATCH_SOURCE_TYPE_DATA_ADD
//        dispatch_source_create(<#T##type: dispatch_source_type_t##dispatch_source_type_t#>, <#T##handle: UInt##UInt#>, <#T##mask: UInt##UInt#>, <#T##queue: dispatch_queue_t!##dispatch_queue_t!#>)
//        DISPATCH_QUEUE_CONCURRENT
        queue.async{
            block();
        }
    }
    
    static func asyncUI(_ block: @escaping ()->()){
        DispatchQueue.main.async{
            block();
        }
    }
}
