//
//  LSCircleProgressView+.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2018. 5. 8..
//  Copyright © 2018년 leesam. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import LSCircleProgressView

extension Reactive where Base: LSCircleProgressView {
    /// Bindable sink for `enabled` property.
    var progress: Binder<Float> {
        return Binder(self.base) { control, value in
            print("binding progress => \(value) \(control)");
            control.progress = value;
        }
    }
}
