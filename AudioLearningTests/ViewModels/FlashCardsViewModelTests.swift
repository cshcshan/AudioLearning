//
//  FlashCardsViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import AudioLearning

final class FlashCardsViewModelTests: XCTestCase {
    typealias FlipData = FlashCardsViewModel.FlipData

    var sut: FlashCardsViewModel!
    var realmService: RealmService<VocabularyRealm>!

    var scheduler: TestScheduler!
    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        setupRealm()
        realmService = RealmService<VocabularyRealm>()
        initStub()
        sut = FlashCardsViewModel(realmService: realmService)
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        flushData()
        sut = nil
        realmService = nil
        super.tearDown()
    }

    func test_vocabularies() {
        let vocabularies = scheduler.createObserver([VocabularyRealm].self)
        sut.state.vocabularies.drive(vocabularies).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, ()),
                .next(20, ())
            ])
            .bind(to: sut.event.fetchData)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(vocabularies.events.count, 3)
        XCTAssertEqual(vocabularies.events[1].value.element?.count, 10)
    }

    func test_flipData() {
        let flipData = scheduler.createObserver(FlipData?.self)
        sut.state.flipData.drive(flipData).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, 0),
                .next(20, 1),
                .next(30, 0),
                .next(40, 1)
            ])
            .bind(to: sut.event.flipCard)
            .disposed(by: bag)

        sut.event.fetchData.accept(())

        scheduler.start()

        XCTAssertEqual(flipData.events.count, 5)
        XCTAssertEqual(flipData.events, [
            .next(0, nil),
            .next(10, FlipData(index: 0, isWordSide: false)),
            .next(20, FlipData(index: 1, isWordSide: false)),
            .next(30, FlipData(index: 0, isWordSide: true)),
            .next(40, FlipData(index: 1, isWordSide: true))
        ])
    }
}

extension FlashCardsViewModelTests {

    private func setupRealm() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "RealmServiceTests"
    }

    private func initStub() {
        var models = [VocabularyRealm]()
        for index in 1...10 {
            let model = VocabularyRealm()
            model.id = "\(index)"
            model.episodeID = "Episode 190815"
            model.word = "Hello \(index)"
            model.note = "World \(index)"
            model.updateDate = Date()
            models.append(model)
        }
        _ = realmService.add(objects: models)
    }

    private func flushData() {
        _ = realmService.deleteAll()
    }
}

// MARK: - FlashCardsViewModel.FlipData + Equatable

extension FlashCardsViewModel.FlipData: Equatable {
    public static func == (lhs: FlashCardsViewModel.FlipData, rhs: FlashCardsViewModel.FlipData) -> Bool {
        lhs.index == rhs.index && lhs.isWordSide == rhs.isWordSide
    }
}
