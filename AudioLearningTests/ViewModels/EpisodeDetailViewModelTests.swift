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
@testable import AudioLearning

class EpisodeDetailViewModelTests: XCTestCase {
    
    var sut: EpisodeDetailViewModel!
    var apiService: MockAPIService!
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        let episodeModel = EpisodeModel(episode: "Episode 190815",
                                        title: "Cryptocurrencies",
                                        desc: "Libra, Bitcoin... would you invest in digital money?",
                                        date: "15 Aug 2019".toDate(dateFormat: "dd MMM yyyy"),
                                        imagePath: "http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg",
                                        path: "/learningenglish/english/features/6-minute-english/ep-190815")
        apiService = MockAPIService()
        sut = EpisodeDetailViewModel(apiService: apiService, episodeModel: episodeModel)
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        apiService = nil
        super.tearDown()
    }
    
    func testInit_Title() {
        XCTAssertEqual(sut.title, "Cryptocurrencies")
    }
    
    func testInit_ScriptHtml() {
        let episodeDetailModel = EpisodeDetailModel(path: "path",
                                                    scriptHtml: "<div><p>Hello</p></div>",
                                                    audioLink: "audio link")
        apiService.episodeDetailReturnValue = .just(episodeDetailModel)
        
        let scriptHtml = scheduler.createObserver(String.self)
        sut.scriptHtml
            .bind(to: scriptHtml)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)
        scheduler.start()
        
        XCTAssertEqual(scriptHtml.events.count, 1)
        XCTAssertEqual(scriptHtml.events, [.next(10, episodeDetailModel.scriptHtml!)])
    }
    
    func testInit_AudioLink() {
        let episodeDetailModel = EpisodeDetailModel(path: "path",
                                                    scriptHtml: "<div><p>Hello</p></div>",
                                                    audioLink: "audio-link")
        apiService.episodeDetailReturnValue = .just(episodeDetailModel)
        
        let audioLink = scheduler.createObserver(String.self)
        sut.audioLink
            .bind(to: audioLink)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)
        scheduler.start()
        
        XCTAssertEqual(audioLink.events.count, 1)
        XCTAssertEqual(audioLink.events, [.next(10, episodeDetailModel.audioLink!)])
    }
    
    func testInit_WithError() {
        let error = NSError(domain: "unit test", code: 2, userInfo: nil)
        let expectingModel = AlertModel(title: "Get Episode List Error",
                                        message: error.localizedDescription)
        apiService.episodeDetailReturnValue = .error(error)
        
        let alert = scheduler.createObserver(AlertModel.self)
        sut.alert
            .bind(to: alert)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(300, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)
        
        // execute reload.flatMapLatest by scriptHtml.subscribe()
        sut.scriptHtml
            .subscribe()
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(alert.events.count, 1)
        XCTAssertEqual(alert.events, [.next(300, expectingModel)])
    }
    
    func testInit_APIPath() {
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)
        
        // execute reload.flatMapLatest by scriptHtml.subscribe()
        sut.scriptHtml
            .subscribe()
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(apiService.episodeDetailPath, "/learningenglish/english/features/6-minute-english/ep-190815")
    }
}
