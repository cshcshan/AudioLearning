//
//  VocabularyListViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class VocabularyListViewModel {
    
    // Inputs and Outputs
    private(set) var hideVocabularyDetailView = BehaviorSubject<Bool>(value: true)
    
    // Inputs
    private(set) var reload: AnyObserver<Void>!
    private(set) var selectVocabulary: AnyObserver<VocabularyRealmModel>!
    private(set) var addVocabulary: AnyObserver<Void>!
    
    // Outputs
    private(set) var vocabularies: Observable<[VocabularyRealmModel]>!
    private(set) var showVocabularyDetail: Observable<VocabularyRealmModel>!
    private(set) var showAddVocabularyDetail: Observable<Void>!
    
    private let reloadSubject = PublishSubject<Void>()
    private let selectVocabularySubject = PublishSubject<VocabularyRealmModel>()
    private let addVocabularySubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    init(realmService: RealmService<VocabularyRealmModel>) {
        reload = reloadSubject.asObserver()
        vocabularies = realmService.allObjects
        selectVocabulary = selectVocabularySubject.asObserver()
        showVocabularyDetail = selectVocabularySubject.asObservable()
        addVocabulary = addVocabularySubject.asObserver()
        showAddVocabularyDetail = addVocabularySubject.asObservable()
        
        Observable.of(showVocabularyDetail.map({ $0 as AnyObject }),
                                                 showAddVocabularyDetail.map({ $0 as AnyObject }))
            .merge()
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.hideVocabularyDetailView.onNext(false)
            })
            .disposed(by: disposeBag)
        
        reloadSubject
            .subscribe(onNext: { (_) in
                realmService.loadAll.onNext(["updateDate": false])
            })
            .disposed(by: disposeBag)
    }
}
