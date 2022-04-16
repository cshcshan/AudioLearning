//
//  ExtensionReactive.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/26.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base == UIView {

    var fadeIn: Binder<TimeInterval> {
        Binder(base, binding: { view, duration in
            UIView.animate(withDuration: duration, animations: {
                view.alpha = 1
            })
        })
    }

    var fadeOut: Binder<TimeInterval> {
        Binder(base, binding: { view, duration in
            UIView.animate(withDuration: duration, animations: {
                view.alpha = 0
            })
        })
    }
}
