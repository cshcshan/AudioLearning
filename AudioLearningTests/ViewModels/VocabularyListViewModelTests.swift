//
//  VocabularyListViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import AudioLearning

class VocabularyListViewModelTests: XCTestCase {

    var realmService: RealmService<VocabularyRealm>!

    var scheduler: TestScheduler!
    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        setupRealm()
        realmService = RealmService<VocabularyRealm>()
        initStub()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        flushData()
        realmService = nil
        super.tearDown()
    }

    func testHideVocabularyDetailView() {
        let sut = VocabularyListViewModel(realmService: realmService, episodeID: nil)

        let hideVocabularyDetailView = scheduler.createObserver(Bool.self)
        sut.hideVocabularyDetailView
            .bind(to: hideVocabularyDetailView)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, false),
            .next(20, true),
            .next(30, true),
            .next(40, true),
            .next(50, false)
        ])
        .bind(to: sut.hideVocabularyDetailView)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(hideVocabularyDetailView.events.count, 6)
        XCTAssertEqual(hideVocabularyDetailView.events, [
            .next(0, true),
            .next(10, false),
            .next(20, true),
            .next(30, true),
            .next(40, true),
            .next(50, false)
        ])
    }

    func testVocabularies_EpisodeIsNotNil() {
        let sut = VocabularyListViewModel(realmService: realmService, episodeID: "Episode 190811")

        let vocabularies = scheduler.createObserver([VocabularyRealm].self)
        sut.vocabularies
            .bind(to: vocabularies)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.reload)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(vocabularies.events.count, 1)
        XCTAssertEqual(vocabularies.events.first?.value.element?.count, 1)
    }

    func testVocabularies_EpisodeIsNil() {
        let sut = VocabularyListViewModel(realmService: realmService, episodeID: nil)

        let vocabularies = scheduler.createObserver([VocabularyRealm].self)
        sut.vocabularies
            .bind(to: vocabularies)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.reload)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(vocabularies.events.count, 1)
        XCTAssertEqual(vocabularies.events.first?.value.element?.count, 10)
    }

    func testShowVocabularyDetail() {
        let sut = VocabularyListViewModel(realmService: realmService, episodeID: nil)

        let model190815 = VocabularyRealm()
        model190815.id = "190815"
        model190815.episodeID = "Episode 190815"
        model190815.word = "Apple"
        model190815.note = "蘋果🍎"
        model190815.updateDate = Date()

        let model190822 = VocabularyRealm()
        model190815.id = "190822"
        model190822.episodeID = "Episode 190822"
        model190822.word = "Phone"
        model190822.note = "手機📱"
        model190822.updateDate = Date()

        let showVocabularyDetail = scheduler.createObserver(VocabularyRealm.self)
        sut.showVocabularyDetail
            .bind(to: showVocabularyDetail)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, model190815),
            .next(20, model190822)
        ])
        .bind(to: sut.selectVocabulary)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(showVocabularyDetail.events, [
            .next(10, model190815),
            .next(20, model190822)
        ])
    }

    func testShowAddVocabularyDetail() {
        let sut = VocabularyListViewModel(realmService: realmService, episodeID: nil)

        let showAddVocabularyDetail = scheduler.createObserver(Void.self)
        sut.showAddVocabularyDetail
            .bind(to: showAddVocabularyDetail)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.addVocabulary)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(showAddVocabularyDetail.events.count, 2)
    }

    func testShowFlashCards() {
        let sut = VocabularyListViewModel(realmService: realmService, episodeID: nil)

        let showFlashCards = scheduler.createObserver(Void.self)
        sut.showFlashCards
            .bind(to: showFlashCards)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.tapFlashCards)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(showFlashCards.events.count, 2)
    }
}

extension VocabularyListViewModelTests {

    private func setupRealm() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "RealmServiceTests"
    }

    private func initStub() {
        var models = [VocabularyRealm]()
        for index in 1...10 {
            let model = VocabularyRealm()
            model.id = "\(index)"
            model.episodeID = "Episode 19081\(index)"
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
