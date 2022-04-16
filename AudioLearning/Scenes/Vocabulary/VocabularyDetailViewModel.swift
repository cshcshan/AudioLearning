//
//  VocabularyDetailViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift

final class VocabularyDetailViewModel: BaseViewModel {

    // Inputs
    private(set) var load: AnyObserver<VocabularyRealm>!
    private(set) var add: AnyObserver<Void>!
    private(set) var addWithWord: AnyObserver<(String?, String)>! // episode and word
    private(set) var save: AnyObserver<VocabularySaveModel>!
    private(set) var cancel: AnyObserver<Void>!

    // Outputs
    private(set) var word = BehaviorSubject<String>(value: "")
    private(set) var note = BehaviorSubject<String>(value: "")
    private(set) var saved: Observable<Void>!
    private(set) var close: Observable<Void>!
    private(set) var alert: Observable<AlertModel>!

    private let loadSubject = PublishSubject<VocabularyRealm>()
    private let addSubject = PublishSubject<Void>()
    private let addWithWordSubject = PublishSubject<(String?, String)>()
    private let saveSubject = PublishSubject<VocabularySaveModel>()
    private let savedSubject = PublishSubject<Void>()
    private let cancelSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    private let alertSubject = PublishSubject<AlertModel>()

    private let realmService: RealmService<VocabularyRealm>
    private var model: VocabularyRealm?
    private var episodeID: String?

    init(realmService: RealmService<VocabularyRealm>) {
        self.realmService = realmService
        super.init()

        self.load = loadSubject.asObserver()
        self.add = addSubject.asObserver()
        self.addWithWord = addWithWordSubject.asObserver()
        self.save = saveSubject.asObserver()
        self.saved = savedSubject.asObservable()
        self.cancel = cancelSubject.asObserver()
        self.close = closeSubject.asObservable()
        self.alert = alertSubject.asObservable()

        realmService.filterObjects
            .subscribe(onNext: { vocabularyRealms in
                guard let model = vocabularyRealms.first else { return }
                self.word.onNext(model.word ?? "")
                self.note.onNext(model.note ?? "")
            })
            .disposed(by: bag)

        loadSubject
            .subscribe(onNext: { [weak self] vocabularyRealm in
                guard let self = self else { return }
                self.model = vocabularyRealm
                self.word.onNext(vocabularyRealm.word ?? "")
                self.note.onNext(vocabularyRealm.note ?? "")
            })
            .disposed(by: bag)

        addSubject
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.model = nil
                self.word.onNext("")
                self.note.onNext("")
            })
            .disposed(by: bag)

        addWithWordSubject
            .subscribe(onNext: { [weak self] episode, word in
                guard let self = self else { return }
                self.model = nil
                self.episodeID = episode
                self.word.onNext(word)
                self.note.onNext("")
                var predicate = NSPredicate(format: "word == %@", word)
                if let episode = episode {
                    let episodePredicate = NSPredicate(format: "id == %@", episode)
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, episodePredicate])
                }
                realmService.filter.onNext((predicate, nil))
            })
            .disposed(by: bag)

        saveSubject
            .subscribe(onNext: { [weak self] saveModel in
                guard let self = self else { return }
                let alert = {
                    let alertModel = AlertModel(title: "Save word failed", message: "Word cannot be empty.")
                    self.alertSubject.onNext(alertModel)
                }
                guard let word = saveModel.word, !word.isEmpty else { return alert() }
                let newModel = VocabularyRealm()
                newModel.id = self.model == nil ? UUID().uuidString : self.model!.id
                newModel.episodeID = self.episodeID
                newModel.word = saveModel.word
                newModel.note = saveModel.note
                newModel.updateDate = Date()
                _ = realmService.add(object: newModel)
                self.savedSubject.onNext(())
                self.closeSubject.onNext(())
            })
            .disposed(by: bag)

        cancelSubject
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.closeSubject.onNext(())
            })
            .disposed(by: bag)
    }
}
