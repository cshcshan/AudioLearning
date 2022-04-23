//
//  FlashCardsViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift

final class FlashCardsViewModel: BaseViewModel {

    struct FlipData {
        let index: Int
        let isWordSide: Bool
    }

    struct State {
        let vocabularies: Driver<[VocabularyRealm]>
        let flipData: Driver<FlipData?>
    }

    struct Event {
        let fetchData = PublishRelay<Void>()
        let flipCard = PublishRelay<Int>()
    }

    // MARK: - Properties

    lazy var state = State(vocabularies: vocabularies.asDriver(), flipData: flipData.asDriver())
    let event = Event()

    private let vocabularies = BehaviorRelay<[VocabularyRealm]>(value: [])
    private let flipData = BehaviorRelay<FlipData?>(value: nil)

    private var wordSideArray: [Bool] = []

    private let realmService: RealmService<VocabularyRealm>

    init(realmService: RealmService<VocabularyRealm>) {
        self.realmService = realmService
        super.init()

        realmService.state.allItems
            .do(onNext: { [weak self] vocabularyRealms in
                self?.wordSideArray = [Bool](repeating: true, count: vocabularyRealms.count)
            })
            .bind(to: vocabularies)
            .disposed(by: bag)

        event.flipCard
            .compactMap { [weak self] index -> FlipData? in
                guard let self = self, self.wordSideArray.indices.contains(index) else { return nil }

                let isWordSide = !self.wordSideArray[index]
                self.wordSideArray[index] = isWordSide
                return FlipData(index: index, isWordSide: isWordSide)
            }
            .bind(to: flipData)
            .disposed(by: bag)

        event.fetchData
            .map { [RealmSortField(fieldName: "updateDate", isAscending: false)] }
            .bind(to: realmService.event.loadAll)
            .disposed(by: bag)
    }
}
