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

    struct State {
        let vocabularies: Driver<[VocabularyRealm]>
        let isVocabularyDetailViewHidden = BehaviorRelay<Bool>(value: true)
    }

    struct Event {
        let fetchData = PublishRelay<Void>()
        let vocabularySelected = PublishRelay<VocabularyRealm>()
        let addVocabulary = PublishRelay<Void>()
        let deleteVocabulary = PublishRelay<VocabularyRealm>()
        let flashCardsTapped = PublishRelay<Void>()
    }

    let state: State
    let event = Event()

    private let episodeID: String?

    init(realmService: RealmService<VocabularyRealm>, episodeID: String?) {
        self.episodeID = episodeID

        let sortFields = [RealmSortField(fieldName: "updateDate", isAscending: false)]

        let vocabularies = Observable
            .merge(
                realmService.state.allItems.asObservable(),
                realmService.state.filterItems.asObservable()
            )
            .asDriver(onErrorJustReturn: [])

        self.state = State(vocabularies: vocabularies)

        super.init()

        Observable
            .merge(event.vocabularySelected.map { _ in }, event.addVocabulary.map { _ in })
            .map { false }
            .observe(on: MainScheduler.instance)
            .bind(to: state.isVocabularyDetailViewHidden)
            .disposed(by: bag)

        let sharedFetchData = event.fetchData.share()

        sharedFetchData
            .compactMap { [episodeID] _ in
                guard let episodeID = episodeID else { return nil }
                let predicate = NSPredicate(format: "episodeID == %@", episodeID)
                return RealmFilter(predicate: predicate, sortFields: sortFields)
            }
            .bind(to: realmService.event.filter)
            .disposed(by: bag)

        sharedFetchData
            .compactMap { [episodeID] _ in
                guard episodeID == nil else { return nil }
                return sortFields
            }
            .bind(to: realmService.event.loadAll)
            .disposed(by: bag)

        event.deleteVocabulary.compactMap(\.id)
            .flatMapLatest {
                realmService.delete(predicate: NSPredicate(format: "id == %@", $0))
            }
            .filter { $0 }
            .map { _ in }
            .bind(to: event.fetchData)
            .disposed(by: bag)
    }
}
