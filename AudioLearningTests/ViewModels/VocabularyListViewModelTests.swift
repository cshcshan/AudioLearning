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

final class VocabularyListViewModelTests: XCTestCase {

    private var realmService: RealmService<VocabularyRealm>!

    private var scheduler: TestScheduler!
    private var bag: DisposeBag!

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

    func test_isVocabularyDetailViewHidden() {
        let sut = VocabularyListViewModel(realmService: realmService, episodeID: nil)

        let isVocabularyDetailViewHidden = scheduler.createObserver(Bool.self)
        sut.state.isVocabularyDetailViewHidden.bind(to: isVocabularyDetailViewHidden).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, false),
                .next(20, true),
                .next(30, true),
                .next(40, true),
                .next(50, false)
            ])
            .bind(to: isVocabularyDetailViewHidden)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isVocabularyDetailViewHidden.events.count, 6)
        XCTAssertEqual(isVocabularyDetailViewHidden.events, [
            .next(0, true),
            .next(10, false),
            .next(20, true),
            .next(30, true),
            .next(40, true),
            .next(50, false)
        ])
    }

    func test_Vocabularies_withNotNullEpisodeID() {
        let sut = VocabularyListViewModel(realmService: realmService, episodeID: "Episode 190811")

        let vocabularies = scheduler.createObserver([VocabularyRealm].self)
        sut.state.vocabularies.drive(vocabularies).disposed(by: bag)
        scheduler.createColdObservable([.next(10, ())]).bind(to: sut.event.fetchData).disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(vocabularies.events.count, 1)
        XCTAssertEqual(vocabularies.events.first?.value.element?.count, 1)
    }

    func test_Vocabularies_withNullEpisodeID() {
        let sut = VocabularyListViewModel(realmService: realmService, episodeID: nil)

        let vocabularies = scheduler.createObserver([VocabularyRealm].self)
        sut.state.vocabularies.drive(vocabularies).disposed(by: bag)
        scheduler.createColdObservable([.next(10, ())]).bind(to: sut.event.fetchData).disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(vocabularies.events.count, 1)
        XCTAssertEqual(vocabularies.events.first?.value.element?.count, 10)
    }
}

extension VocabularyListViewModelTests {

    private func setupRealm() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "RealmServiceTests"
    }

    private func initStub() {
        let models: [VocabularyRealm] = (1...10).map { index in
            let model = VocabularyRealm()
            model.id = "\(index)"
            model.episodeID = "Episode 19081\(index)"
            model.word = "Hello \(index)"
            model.note = "World \(index)"
            model.updateDate = Date()
            return model
        }
        _ = realmService.add(objects: models)
    }

    private func flushData() {
        _ = realmService.deleteAll()
    }
}
