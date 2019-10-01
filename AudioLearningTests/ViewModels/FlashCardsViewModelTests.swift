//
//  FlashCardsViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import RealmSwift
import RxTest
import RxSwift
import RxCocoa
@testable import AudioLearning

class FlashCardsViewModelTests: XCTestCase {
    
    var sut: FlashCardsViewModel!
    var realmService: RealmService<VocabularyRealmModel>!
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        setupRealm()
        realmService = RealmService<VocabularyRealmModel>()
        initStub()
        sut = FlashCardsViewModel(realmService: realmService)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        flushData()
        sut = nil
        realmService = nil
        super.tearDown()
    }
    
    func testVocabularies() {
        let vocabularies = scheduler.createObserver([VocabularyRealmModel].self)
        sut.vocabularies
            .bind(to: vocabularies)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ()),
                                        .next(20, ())])
            .bind(to: sut.load)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(vocabularies.events.count, 2)
        XCTAssertEqual(vocabularies.events.first?.value.element?.count, 10)
    }
    
    func testIsWordSide() {
        let isWordSide = scheduler.createObserver(Bool.self)
        sut.isWordSide
            .bind(to: isWordSide)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ()),
                                        .next(20, ())])
            .bind(to: sut.flip)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(isWordSide.events.count, 3)
        XCTAssertEqual(isWordSide.events, [.next(0, true),
                                           .next(10, false),
                                           .next(20, true)])
    }
}

extension FlashCardsViewModelTests {
    
    private func setupRealm() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "RealmServiceTests"
    }
    
    private func initStub() {
        var models = [VocabularyRealmModel]()
        for index in 1...10 {
            let model = VocabularyRealmModel()
            model.id = "\(index)"
            model.episode = "Episode 190815"
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
