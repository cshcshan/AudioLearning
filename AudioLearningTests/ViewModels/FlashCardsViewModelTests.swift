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

class FlashCardsViewModelTests: XCTestCase {

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

    func testVocabularies() {
        let vocabularies = scheduler.createObserver([VocabularyRealm].self)
        sut.vocabularies
            .bind(to: vocabularies)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.load)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(vocabularies.events.count, 2)
        XCTAssertEqual(vocabularies.events.first?.value.element?.count, 10)
    }

    func testIsWordSide() {
        let isWordSide = scheduler.createObserver(Bool.self)
        sut.isWordSide
            .bind(to: isWordSide)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, 0),
            .next(20, 1),
            .next(30, 0),
            .next(40, 1)
        ])
        .bind(to: sut.flip)
        .disposed(by: bag)
        sut.load.onNext(())
        scheduler.start()
        XCTAssertEqual(isWordSide.events.count, 4)
        XCTAssertEqual(isWordSide.events, [
            .next(10, false),
            .next(20, false),
            .next(30, true),
            .next(40, true)
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
