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

    init(realmService: RealmService<VocabularyRealm>) {
        self.setEpisode = setEpisodeSubject.asObserver()
        self.reload = reloadSubject.asObserver()
        self.vocabularies = Observable.merge(realmService.allObjects, realmService.filterObjects)
        self.selectVocabulary = selectVocabularySubject.asObserver()
        self.showVocabularyDetail = selectVocabularySubject.asObservable()
        self.addVocabulary = addVocabularySubject.asObserver()
        self.showAddVocabularyDetail = addVocabularySubject.asObservable()
        self.deleteVocabulary = deleteVocabularySubject.asObserver()
        self.tapFlashCards = tapFlashCardsSubject.asObserver()
        self.showFlashCards = tapFlashCardsSubject.asObservable()
        super.init()

        Observable
            .merge(showVocabularyDetail.map { _ in }, showAddVocabularyDetail.map { _ in })
            .map { false }
            .observe(on: MainScheduler.instance)
            .bind(to: hideVocabularyDetailView)
            .disposed(by: bag)

        let sharedReloadSubject = reloadSubject.share()

        sharedReloadSubject
            .withLatestFrom(setEpisodeSubject)
            .compactMap { episode in
                guard let episode = episode else { return nil }
                let sortedByAsc = ["updateDate": false]
                return (NSPredicate(format: "episode == %@", episode), sortedByAsc)
            }
            .bind(to: realmService.filter)
            .disposed(by: bag)

        sharedReloadSubject
            .withLatestFrom(setEpisodeSubject)
            .debug()
            .compactMap { episode in
                guard episode == nil else { return nil }
                let sortedByAsc = ["updateDate": false]
                return sortedByAsc
            }
            .bind(to: realmService.loadAll)
            .disposed(by: bag)

        let deleteSuccessfully = PublishSubject<Bool>()
        deleteSuccessfully.filter { $0 }.map { _ in }.bind(to: reloadSubject).disposed(by: bag)

        deleteVocabularySubject.compactMap(\.id)
            .flatMapLatest { realmService.delete(predicate: NSPredicate(format: "id == %@", $0)) }
            .bind(to: deleteSuccessfully)
            .disposed(by: bag)
    }
}
