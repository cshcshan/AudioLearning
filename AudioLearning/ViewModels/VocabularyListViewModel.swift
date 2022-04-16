//
//  VocabularyListViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class VocabularyListViewModel: BaseViewModel {

    // Inputs and Outputs
    private(set) var hideVocabularyDetailView = BehaviorSubject<Bool>(value: true)

    // Inputs
    private(set) var setEpisode: AnyObserver<String?>!
    private(set) var reload: AnyObserver<Void>!
    private(set) var selectVocabulary: AnyObserver<VocabularyRealm>!
    private(set) var addVocabulary: AnyObserver<Void>!
    private(set) var deleteVocabulary: AnyObserver<VocabularyRealm>!
    private(set) var tapFlashCards: AnyObserver<Void>!

    // Outputs
    private(set) var vocabularies: Observable<[VocabularyRealm]>!
    private(set) var showVocabularyDetail: Observable<VocabularyRealm>!
    private(set) var showAddVocabularyDetail: Observable<Void>!
    private(set) var showFlashCards: Observable<Void>!

    private let setEpisodeSubject = PublishSubject<String?>()
    private let reloadSubject = PublishSubject<Void>()
    private let selectVocabularySubject = PublishSubject<VocabularyRealm>()
    private let addVocabularySubject = PublishSubject<Void>()
    private let deleteVocabularySubject = PublishSubject<VocabularyRealm>()
    private let tapFlashCardsSubject = PublishSubject<Void>()

    private var episode: String?

    init(realmService: RealmService<VocabularyRealm>) {
        self.setEpisode = setEpisodeSubject.asObserver()
        self.reload = reloadSubject.asObserver()
        self.vocabularies = Observable.of(realmService.allObjects, realmService.filterObjects).merge()
        self.selectVocabulary = selectVocabularySubject.asObserver()
        self.showVocabularyDetail = selectVocabularySubject.asObservable()
        self.addVocabulary = addVocabularySubject.asObserver()
        self.showAddVocabularyDetail = addVocabularySubject.asObservable()
        self.deleteVocabulary = deleteVocabularySubject.asObserver()
        self.tapFlashCards = tapFlashCardsSubject.asObserver()
        self.showFlashCards = tapFlashCardsSubject.asObservable()
        super.init()

        Observable.of(
            showVocabularyDetail.map { $0 as AnyObject },
            showAddVocabularyDetail.map { $0 as AnyObject }
        )
        .merge()
        .subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.hideVocabularyDetailView.onNext(false)
        })
        .disposed(by: bag)

        setEpisodeSubject
            .subscribe(onNext: { [weak self] episode in
                guard let self = self else { return }
                self.episode = episode
            })
            .disposed(by: bag)

        reloadSubject
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let sortedByAsc = ["updateDate": false]
                if let episode = self.episode {
                    realmService.filter.onNext((NSPredicate(format: "episode == %@", episode), sortedByAsc))
                } else {
                    realmService.loadAll.onNext(sortedByAsc)
                }
            })
            .disposed(by: bag)

        let deleteSuccessSubject = PublishSubject<Bool>()
        deleteSuccessSubject
            .subscribe(onNext: { [weak self] success in
                guard let self = self else { return }
                guard success else { return }
                self.reloadSubject.onNext(())
            })
            .disposed(by: bag)

        deleteVocabularySubject
            .subscribe(onNext: { [weak self] vocabularyRealm in
                guard let self = self else { return }
                guard let id = vocabularyRealm.id else { return }
                realmService.delete(predicate: NSPredicate(format: "id == %@", id))
                    .subscribe(onNext: { success in
                        deleteSuccessSubject.onNext(success)
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
    }
}
