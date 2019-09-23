//
//  VocabularyDetailViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import RxCocoa

class VocabularyDetailViewModel {
    
    // Inputs
    private(set) var load: AnyObserver<VocabularyRealmModel>!
    private(set) var save: AnyObserver<VocabularyRealmModel>!
    private(set) var cancel: AnyObserver<Void>!
    
    // Outputs
    private(set) var word = BehaviorSubject<String>(value: "")
    private(set) var note = BehaviorSubject<String>(value: "")
    private(set) var close: Observable<Void>!
    
    private let loadSubject = PublishSubject<VocabularyRealmModel>()
    private let saveSubject = PublishSubject<VocabularyRealmModel>()
    private let cancelSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(realmService: RealmService<VocabularyRealmModel>) {
        load = loadSubject.asObserver()
        save = saveSubject.asObserver()
        cancel = cancelSubject.asObserver()
        close = closeSubject.asObservable()
        
        loadSubject
            .subscribe(onNext: { [weak self] (vocabularyRealmModel) in
                guard let `self` = self else { return }
                self.word.onNext(vocabularyRealmModel.word ?? "")
                self.note.onNext(vocabularyRealmModel.note ?? "")
            })
            .disposed(by: disposeBag)
        
        saveSubject
            .subscribe(onNext: { [weak self] (vocabularyRealmModel) in
                guard let `self` = self else { return }
                _ = realmService.add(object: vocabularyRealmModel)
                self.closeSubject.onNext(())
            })
            .disposed(by: disposeBag)
        
        cancelSubject
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.closeSubject.onNext(())
            })
            .disposed(by: disposeBag)
    }
}
