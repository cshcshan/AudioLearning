//
//  FlashCardsViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import RxCocoa

class FlashCardsViewModel {
    
    // Inputs
    private(set) var load: AnyObserver<Void>!
    private(set) var flip: AnyObserver<Void>!
    
    // Outputs
    private(set) var vocabularies: Observable<[VocabularyRealmModel]>!
    private(set) var isWordSide = BehaviorSubject<Bool>(value: true)
    
    private let loadSubject = PublishSubject<Void>()
    private let flipSubject = PublishSubject<Void>()
    private let vocabulariesSubject = PublishSubject<Void>()
    
    private var realmService: RealmService<VocabularyRealmModel>
    private let disposeBag = DisposeBag()
    
    init(realmService: RealmService<VocabularyRealmModel>) {
        self.realmService = realmService
        
        load = loadSubject.asObserver()
        flip = flipSubject.asObserver()
        vocabularies = realmService.allObjects
        
        loadSubject
            .subscribe(onNext: { (_) in
                realmService.loadAll.onNext(["updateDate": false])
            })
            .disposed(by: disposeBag)
        
        flipSubject
            .scan(true) { (aggregateValue, _) in !aggregateValue }
            .subscribe(onNext: { [weak self] (isWordSide) in
                guard let `self` = self else { return }
                self.isWordSide.onNext(isWordSide)
            })
            .disposed(by: disposeBag)
    }
}
