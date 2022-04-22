//
//  EpisodeDetailViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/3.
//  Copyright © 2019 cshan. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import AudioLearning

final class EpisodeDetailViewModelTests: XCTestCase {

    var sut: EpisodeDetailViewModel!
    var apiService: MockAPIService!
    var realmService: RealmService<EpisodeDetailRealm>!
    var episode: Episode!

    var scheduler: TestScheduler!
    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "unit-testing-db"
        episode = Episode(
            id: "Episode 190815",
            title: "Cryptocurrencies",
            desc: "Libra, Bitcoin... would you invest in digital money?",
            date: "15 Aug 2019".date(withDateFormat: "dd MMM yyyy"),
            imagePath: "http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg",
            path: "/learningenglish/english/features/6-minute-english/ep-190815"
        )
        apiService = MockAPIService()
        realmService = RealmService()
        sut = EpisodeDetailViewModel(apiService: apiService, realmService: realmService, episode: episode)

        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        apiService = nil
        super.tearDown()
    }

    func test_shrinkAudioPlayer() {
        let shrinkAudioPlayer = scheduler.createObserver(Void.self)
        sut.event.shrinkAudioPlayer.bind(to: shrinkAudioPlayer).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, ()),
                .next(20, ())
            ])
            .bind(to: sut.event.shrinkAudioPlayer)
            .disposed(by: bag)

        scheduler.start()
        XCTAssertEqual(shrinkAudioPlayer.events.count, 2)
    }

    func test_enlargeAudioPlayer() {
        let enlargeAudioPlayer = scheduler.createObserver(Void.self)
        sut.event.enlargeAudioPlayer.bind(to: enlargeAudioPlayer).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, ()),
                .next(20, ())
            ])
            .bind(to: sut.event.enlargeAudioPlayer)
            .disposed(by: bag)

        scheduler.start()
        XCTAssertEqual(enlargeAudioPlayer.events.count, 2)
    }

    func test_title() {
        XCTAssertEqual(sut.title, "Cryptocurrencies")
    }

    func test_scriptHtml() {
        let episodeDetailRealm = EpisodeDetailRealm()
        episodeDetailRealm.id = episode.id
        episodeDetailRealm.path = "path"
        episodeDetailRealm.scriptHtml = "<div><p>Hello</p></div>"
        episodeDetailRealm.audioLink = "audio link"
        apiService.episodeDetailReturnValue = .just(episodeDetailRealm)

        let scriptHtmlString = scheduler.createObserver(String.self)
        sut.state.scriptHtmlString.drive(scriptHtmlString).disposed(by: bag)

        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.event.fetchData)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(scriptHtmlString.events.count, 2)
        XCTAssertEqual(scriptHtmlString.events, [
            .next(0, ""),
            .next(10, episodeDetailRealm.scriptHtml!)
        ])
    }

    func test_audioURLString() {
        let episodeDetailRealm = EpisodeDetailRealm()
        episodeDetailRealm.id = episode.id
        episodeDetailRealm.path = "path"
        episodeDetailRealm.scriptHtml = "<div><p>Hello</p></div>"
        episodeDetailRealm.audioLink = "audio-link"
        apiService.episodeDetailReturnValue = .just(episodeDetailRealm)

        let audioURLString = scheduler.createObserver(String.self)
        sut.state.audioURLString.drive(audioURLString).disposed(by: bag)

        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.event.fetchData)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(audioURLString.events.count, 2)
        XCTAssertEqual(
            audioURLString.events,
            [.next(0, ""), .next(10, episodeDetailRealm.audioLink!)]
        )
    }

    func test_init_withError() {
        let error = NSError(domain: "unit test", code: 2, userInfo: nil)
        let expectingModel = AlertModel(
            title: "Get Episode Detail Error",
            message: error.localizedDescription
        )
        apiService.episodeDetailReturnValue = .error(error)

        let alert = scheduler.createObserver(AlertModel.self)
        sut.event.showAlert.bind(to: alert).disposed(by: bag)

        scheduler.createColdObservable([.next(300, ())])
            .bind(to: sut.event.fetchData)
            .disposed(by: bag)

        sut.state.scriptHtmlString.drive().disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(alert.events.count, 1)
        XCTAssertEqual(alert.events, [.next(300, expectingModel)])
    }

    func test_episode() {
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.event.fetchData)
            .disposed(by: bag)

        sut.state.scriptHtmlString.drive().disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(apiService.episodeDetailPath, episode.id)
    }
}
