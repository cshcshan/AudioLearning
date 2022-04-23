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

    private(set) var wordSideArray: [Bool] = []

    // Inputs
    private(set) var load: AnyObserver<Void>!
    private(set) var flip: AnyObserver<Int>! // index

    // Outputs
    private(set) var vocabularies: Observable<[VocabularyRealm]>!
    private(set) var isWordSide: Observable<Bool>!

    private let loadSubject = PublishSubject<Void>()
    private let flipSubject = PublishSubject<Int>()
    private let isWordSideSubject = PublishSubject<Bool>()

    private var realmService: RealmService<VocabularyRealm>

    init(realmService: RealmService<VocabularyRealm>) {
        self.realmService = realmService
        super.init()

        self.load = loadSubject.asObserver()
        self.flip = flipSubject.asObserver()
        self.isWordSide = isWordSideSubject.asObserver()
        self.vocabularies = realmService.state.allItems.asObservable()

        vocabularies
            .subscribe(onNext: { [weak self] vocabularyRealms in
                guard let self = self else { return }
                self.wordSideArray = [Bool](repeating: true, count: vocabularyRealms.count)
            })
            .disposed(by: bag)

        loadSubject
            .map { [RealmSortField(fieldName: "updateDate", isAscending: false)] }
            .bind(to: realmService.event.loadAll)
            .disposed(by: bag)

        flipSubject
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                let value = !self.wordSideArray[index]
                self.wordSideArray[index] = value
                self.isWordSideSubject.onNext(value)
            })
            .disposed(by: bag)
    }
}
