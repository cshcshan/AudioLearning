//
//  FlashCardsViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import RxCocoa

final class FlashCardsViewModel: BaseViewModel {
    
    private(set) var wordSideArray: [Bool] = []
    
    // Inputs
    private(set) var load: AnyObserver<Void>!
    private(set) var flip: AnyObserver<Int>! // index
    
    // Outputs
    private(set) var vocabularies: Observable<[VocabularyRealmModel]>!
    private(set) var isWordSide: Observable<Bool>!
    
    private let loadSubject = PublishSubject<Void>()
    private let flipSubject = PublishSubject<Int>()
    private let isWordSideSubject = PublishSubject<Bool>()
    
    private var realmService: RealmService<VocabularyRealmModel>
    
    init(realmService: RealmService<VocabularyRealmModel>) {
        self.realmService = realmService
        super.init()
        
        load = loadSubject.asObserver()
        flip = flipSubject.asObserver()
        isWordSide = isWordSideSubject.asObserver()
        vocabularies = realmService.allObjects
        realmService.allObjects
            .subscribe(onNext: { [weak self] (vocabularyRealmModels) in
                guard let `self` = self else { return }
                self.wordSideArray = [Bool](repeating: true, count: vocabularyRealmModels.count)
            })
            .disposed(by: disposeBag)
        
        loadSubject
            .subscribe(onNext: { (_) in
                realmService.loadAll.onNext(["updateDate": false])
            })
            .disposed(by: disposeBag)
        
        flipSubject
            .subscribe(onNext: { [weak self] (index) in
                guard let `self` = self else { return }
                let value = !self.wordSideArray[index]
                self.wordSideArray[index] = value
                self.isWordSideSubject.onNext(value)
            })
            .disposed(by: disposeBag)
    }
}
