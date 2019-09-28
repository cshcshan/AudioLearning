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
    private(set) var addWithWord: AnyObserver<(String?, String)>! // episode and word
    private(set) var save: AnyObserver<(VocabularySaveModel)>!
    private(set) var cancel: AnyObserver<Void>!
    
    // Outputs
    private(set) var word = BehaviorSubject<String>(value: "")
    private(set) var note = BehaviorSubject<String>(value: "")
    private(set) var saved: Observable<Void>!
    private(set) var close: Observable<Void>!
    private(set) var alert: Observable<AlertModel>!
    
    private let loadSubject = PublishSubject<VocabularyRealmModel>()
    private let addSubject = PublishSubject<Void>()
    private let addWithWordSubject = PublishSubject<(String?, String)>()
    private let saveSubject = PublishSubject<VocabularySaveModel>()
    private let savedSubject = PublishSubject<Void>()
    private let cancelSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    private let alertSubject = PublishSubject<AlertModel>()
    
    private let realmService: RealmService<VocabularyRealmModel>
    private var model: VocabularyRealmModel?
    private var episode: String?
    private let disposeBag = DisposeBag()
    
    init(realmService: RealmService<VocabularyRealmModel>) {
        self.realmService = realmService
        
        load = loadSubject.asObserver()
        add = addSubject.asObserver()
        addWithWord = addWithWordSubject.asObserver()
        save = saveSubject.asObserver()
        saved = savedSubject.asObservable()
        cancel = cancelSubject.asObserver()
        close = closeSubject.asObservable()
        alert = alertSubject.asObservable()
        
        realmService.filterObjects
            .subscribe(onNext: { (vocabularyRealmModels) in
                guard let model = vocabularyRealmModels.first else { return }
                self.word.onNext(model.word ?? "")
                self.note.onNext(model.note ?? "")
            })
            .disposed(by: disposeBag)
        
        loadSubject
            .subscribe(onNext: { [weak self] (vocabularyRealmModel) in
                guard let `self` = self else { return }
                self.model = vocabularyRealmModel
                self.word.onNext(vocabularyRealmModel.word ?? "")
                self.note.onNext(vocabularyRealmModel.note ?? "")
            })
            .disposed(by: disposeBag)
        
        addSubject
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.model = nil
                self.word.onNext("")
                self.note.onNext("")
            })
            .disposed(by: disposeBag)
        
        addWithWordSubject
            .subscribe(onNext: { [weak self] (episode, word) in
                guard let `self` = self else { return }
                self.model = nil
                self.episode = episode
                self.word.onNext(word)
                self.note.onNext("")
                var predicate: NSPredicate = NSPredicate(format: "word == %@", word)
                if let episode = episode {
                    let episodePredicate = NSPredicate(format: "episode == %@", episode)
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, episodePredicate])
                }
                realmService.filter.onNext((predicate, nil))
            })
            .disposed(by: disposeBag)
        
        saveSubject
            .subscribe(onNext: { [weak self] (saveModel) in
                guard let `self` = self else { return }
                let alert = {
                    let alertModel = AlertModel(title: "Save word failed", message: "Word cannot be empty.")
                    self.alertSubject.onNext(alertModel)
                }
                guard let word = saveModel.word else { return alert() }
                guard word.count > 0 else { return alert() }
                let newModel = VocabularyRealmModel()
                newModel.id = self.model == nil ? UUID().uuidString : self.model!.id
                newModel.episode = self.episode
                newModel.word = saveModel.word
                newModel.note = saveModel.note
                newModel.updateDate = Date()
                _ = realmService.add(object: newModel)
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
