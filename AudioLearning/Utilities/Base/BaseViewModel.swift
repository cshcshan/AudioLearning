//
//  BaseViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/5.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class BaseViewModel {

    // Inputs
    private(set) var tapTheme: AnyObserver<Void>!
    private(set) var tapPlaying: AnyObserver<Void>!

    // Outputs
    private(set) var showEpisodeDetailFromPlaying: Observable<Void>!

    private let tapThemeSubject = PublishSubject<Void>()
    private let tapPlayingSubject = PublishSubject<Void>()

    let bag = DisposeBag()

    init() {
        self.tapTheme = tapThemeSubject.asObserver()
        self.tapPlaying = tapPlayingSubject.asObserver()
        self.showEpisodeDetailFromPlaying = tapPlayingSubject.asObservable()

        tapThemeSubject
            .subscribe(onNext: { _ in
                Appearance.mode = Appearance.mode == .dark ? .light : .dark
                NotificationCenter.default.post(name: .changeAppearance, object: nil)
            })
            .disposed(by: bag)
    }
}
