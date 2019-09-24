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
    private(set) var add: AnyObserver<Void>!
    private(set) var save: AnyObserver<(VocabularySaveModel)>!
    private(set) var cancel: AnyObserver<Void>!
    
    // Outputs
    private(set) var word = BehaviorSubject<String>(value: "")
    private(set) var note = BehaviorSubject<String>(value: "")
    private(set) var saved: Observable<Void>!
    private(set) var close: Observable<Void>!
    
    private let loadSubject = PublishSubject<VocabularyRealmModel>()
    private let addSubject = PublishSubject<Void>()
    private let saveSubject = PublishSubject<VocabularySaveModel>()
    private let savedSubject = PublishSubject<Void>()
    private let cancelSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    
    private let realmService: RealmService<VocabularyRealmModel>
    private var model: VocabularyRealmModel?
    private let disposeBag = DisposeBag()
    
    init(realmService: RealmService<VocabularyRealmModel>) {
        self.realmService = realmService
        
        load = loadSubject.asObserver()
        add = addSubject.asObserver()
        save = saveSubject.asObserver()
        saved = savedSubject.asObservable()
        cancel = cancelSubject.asObserver()
        close = closeSubject.asObservable()
        
        loadSubject
            .subscribe(onNext: { [weak self] (vocabularyRealmModel) in
                guard let `self` = self else { return }
                self.word.onNext(vocabularyRealmModel.word ?? "")
                self.note.onNext(vocabularyRealmModel.note ?? "")
            })
            .disposed(by: disposeBag)
        
        addSubject
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.word.onNext("")
                self.note.onNext("")
            })
            .disposed(by: disposeBag)
        
        saveSubject
            .subscribe(onNext: { [weak self] (saveModel) in
                guard let `self` = self else { return }
                let model = VocabularyRealmModel()
                model.episode = saveModel.episode
                model.word = saveModel.word
                model.note = saveModel.note
                model.updateDate = Date()
                _ = realmService.add(object: model)
                self.savedSubject.onNext(())
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
