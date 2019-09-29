//
//  EpisodeDetailViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/3.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
import RealmSwift
@testable import AudioLearning

class EpisodeDetailViewModelTests: XCTestCase {
    
    var sut: EpisodeDetailViewModel!
    var apiService: MockAPIService!
    var realmService: RealmService<EpisodeDetailRealmModel>!
    var episodeModel: EpisodeModel!
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "unit-testing-db"
        episodeModel = EpisodeModel(episode: "Episode 190815",
                                    title: "Cryptocurrencies",
                                    desc: "Libra, Bitcoin... would you invest in digital money?",
                                    date: "15 Aug 2019".toDate(dateFormat: "dd MMM yyyy"),
                                    imagePath: "http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg",
                                    path: "/learningenglish/english/features/6-minute-english/ep-190815")
        apiService = MockAPIService()
        realmService = RealmService()
        sut = EpisodeDetailViewModel(apiService: apiService, realmService: realmService, episodeModel: episodeModel)
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        apiService = nil
        super.tearDown()
    }
    
    func testShrinkMusicPlayer() {
        let shrinkMusicPlayer = scheduler.createObserver(Void.self)
        sut.shrinkMusicPlayer
            .bind(to: shrinkMusicPlayer)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ()),
                                        .next(20, ())])
            .bind(to: sut.shrinkMusicPlayer)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(shrinkMusicPlayer.events.count, 2)
    }
    
    func testEnlargeMusicPlayer() {
        let enlargeMusicPlayer = scheduler.createObserver(Void.self)
        sut.enlargeMusicPlayer
            .bind(to: enlargeMusicPlayer)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ()),
                                        .next(20, ())])
            .bind(to: sut.enlargeMusicPlayer)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(enlargeMusicPlayer.events.count, 2)
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
    
    func testTitle() {
        XCTAssertEqual(sut.title, "Cryptocurrencies")
    }
    
    func testScriptHtml() {
        let episodeDetailRealmModel = EpisodeDetailRealmModel()
        episodeDetailRealmModel.episode = episodeModel.episode
        episodeDetailRealmModel.path = "path"
        episodeDetailRealmModel.scriptHtml = "<div><p>Hello</p></div>"
        episodeDetailRealmModel.audioLink = "audio link"
        apiService.episodeDetailReturnValue = .just(episodeDetailRealmModel)
        
        let scriptHtml = scheduler.createObserver(String.self)
        sut.scriptHtml
            .bind(to: scriptHtml)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.load)
            .disposed(by: disposeBag)
        scheduler.start()
        
        XCTAssertEqual(scriptHtml.events.count, 2)
        XCTAssertEqual(scriptHtml.events, [.next(0, ""),
                                           .next(10, episodeDetailRealmModel.scriptHtml!)])
    }
    
    func testAudioLink() {
        let episodeDetailRealmModel = EpisodeDetailRealmModel()
        episodeDetailRealmModel.episode = episodeModel.episode
        episodeDetailRealmModel.path = "path"
        episodeDetailRealmModel.scriptHtml = "<div><p>Hello</p></div>"
        episodeDetailRealmModel.audioLink = "audio-link"
        apiService.episodeDetailReturnValue = .just(episodeDetailRealmModel)
        
        let audioLink = scheduler.createObserver(String.self)
        sut.audioLink
            .bind(to: audioLink)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.load)
            .disposed(by: disposeBag)
        scheduler.start()
        
        XCTAssertEqual(audioLink.events.count, 1)
        XCTAssertEqual(audioLink.events, [.next(10, episodeDetailRealmModel.audioLink!)])
    }
    
    func testShowVocabulary() {
        let showVocabulary = scheduler.createObserver(Void.self)
        sut.showVocabulary
            .bind(to: showVocabulary)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ()),
                                        .next(20, ())])
            .bind(to: sut.tapVocabulary)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(showVocabulary.events.count, 2)
    }
    
    func testShowAddVocabularyDetail() {
        let showAddVocabularyDetail = scheduler.createObserver(String.self)
        sut.showAddVocabularyDetail
            .bind(to: showAddVocabularyDetail)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, "Hello"),
                                        .next(20, "World")])
            .bind(to: sut.addVocabulary)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(showAddVocabularyDetail.events.count, 2)
        XCTAssertEqual(showAddVocabularyDetail.events, [.next(10, "Hello"),
                                                        .next(20, "World")])
    }
    
    func testInit_WithError() {
        let error = NSError(domain: "unit test", code: 2, userInfo: nil)
        let expectingModel = AlertModel(title: "Load Episode Detail Error",
                                        message: error.localizedDescription)
        apiService.episodeDetailReturnValue = .error(error)
        
        let alert = scheduler.createObserver(AlertModel.self)
        sut.alert
            .bind(to: alert)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(300, ())])
            .bind(to: sut.load)
            .disposed(by: disposeBag)
        
        // execute reload.flatMapLatest by scriptHtml.subscribe()
        sut.scriptHtml
            .subscribe()
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(alert.events.count, 1)
        XCTAssertEqual(alert.events, [.next(300, expectingModel)])
    }
    
    func testEpisode() {
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.load)
            .disposed(by: disposeBag)
        
        // execute reload.flatMapLatest by scriptHtml.subscribe()
        sut.scriptHtml
            .subscribe()
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(apiService.episodeDetailPath, episodeModel.episode)
    }
}
