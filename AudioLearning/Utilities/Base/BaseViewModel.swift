//
//  BaseViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/5.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class BaseViewModel {
    
    // Input
    private(set) var tapTheme: AnyObserver<Void>!
    
    private let tapThemeSubject = PublishSubject<Void>()
    
    let disposeBag = DisposeBag()
    
    init() {
        tapTheme = tapThemeSubject.asObserver()
        
        tapThemeSubject
            .subscribe(onNext: { (_) in
                Appearance.mode = Appearance.mode == .dark ? .light : .dark
                NotificationCenter.default.post(name: .changeAppearance, object: nil)
            })
            .disposed(by: disposeBag)
    }
}
