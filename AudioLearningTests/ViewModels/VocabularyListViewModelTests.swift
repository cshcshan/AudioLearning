//
//  VocabularyListViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import RealmSwift
import RxTest
import RxSwift
import RxCocoa
@testable import AudioLearning

class VocabularyListViewModelTests: XCTestCase {
    
    var sut: VocabularyListViewModel!
    var realmService: RealmService<VocabularyRealmModel>!
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        setupRealm()
        realmService = RealmService<VocabularyRealmModel>()
        initStub()
        sut = VocabularyListViewModel(realmService: realmService)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        flushData()
        sut = nil
        realmService = nil
        super.tearDown()
    }
    
    func testHideVocabularyDetailView() {
        let hideVocabularyDetailView = scheduler.createObserver(Bool.self)
        sut.hideVocabularyDetailView
            .bind(to: hideVocabularyDetailView)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, false),
                                        .next(20, true),
                                        .next(30, true),
                                        .next(40, true),
                                        .next(50, false)])
            .bind(to: sut.hideVocabularyDetailView)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(hideVocabularyDetailView.events.count, 6)
        XCTAssertEqual(hideVocabularyDetailView.events, [.next(0, true),
                                                         .next(10, false),
                                                         .next(20, true),
                                                         .next(30, true),
                                                         .next(40, true),
                                                         .next(50, false)])
    }
    
    func testVocabularies_EpisodeIsNotNil() {
        let vocabularies = scheduler.createObserver([VocabularyRealmModel].self)
        sut.vocabularies
            .bind(to: vocabularies)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(5, "Episode 190811")])
            .bind(to: sut.setEpisode)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(vocabularies.events.count, 1)
        XCTAssertEqual(vocabularies.events.first?.value.element?.count, 1)
    }
    
    func testVocabularies_EpisodeIsNil() {
        let vocabularies = scheduler.createObserver([VocabularyRealmModel].self)
        sut.vocabularies
            .bind(to: vocabularies)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(vocabularies.events.count, 1)
        XCTAssertEqual(vocabularies.events.first?.value.element?.count, 10)
    }
    
    func testShowVocabularyDetail() {
        let model190815 = VocabularyRealmModel()
        model190815.id = "190815"
        model190815.episode = "Episode 190815"
        model190815.word = "Apple"
        model190815.note = "蘋果🍎"
        model190815.updateDate = Date()
        
        let model190822 = VocabularyRealmModel()
        model190815.id = "190822"
        model190822.episode = "Episode 190822"
        model190822.word = "Phone"
        model190822.note = "手機📱"
        model190822.updateDate = Date()
        
        let showVocabularyDetail = scheduler.createObserver(VocabularyRealmModel.self)
        sut.showVocabularyDetail
            .bind(to: showVocabularyDetail)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, model190815),
                                        .next(20, model190822)])
            .bind(to: sut.selectVocabulary)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(showVocabularyDetail.events, [.next(10, model190815),
                                                     .next(20, model190822)])
    }
    
    func testShowAddVocabularyDetail() {
        let showAddVocabularyDetail = scheduler.createObserver(Void.self)
        sut.showAddVocabularyDetail
            .bind(to: showAddVocabularyDetail)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ()),
                                        .next(20, ())])
            .bind(to: sut.addVocabulary)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(showAddVocabularyDetail.events.count, 2)
    }
}

extension VocabularyListViewModelTests {
    
    private func setupRealm() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "RealmServiceTests"
    }
    
    private func initStub() {
        var models = [VocabularyRealmModel]()
        for index in 1...10 {
            let model = VocabularyRealmModel()
            model.id = "\(index)"
            model.episode = "Episode 19081\(index)"
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
