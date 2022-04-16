//
//  EpisodeListViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/2.
//  Copyright © 2019 cshan. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import AudioLearning

// swiftlint:disable force_try
class EpisodeListViewModelTests: XCTestCase {

    var sut: EpisodeListViewModel!
    var apiService: MockAPIService!
    var realmService: RealmService<EpisodeRealm>!

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "unit-testing-db"
        apiService = MockAPIService()
        realmService = RealmService()
        sut = EpisodeListViewModel(apiService: apiService, realmService: realmService)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        apiService = nil
        super.tearDown()
    }

    func testEpisodes() {
        let bundle = Bundle(for: type(of: self))
        let urlString = bundle.path(forResource: "6-minute-english", ofType: "html")!
        let url = URL(fileURLWithPath: urlString)
        let html = try! String(contentsOf: url)
        let episodesModels = ParseSixMinutesHelper().parseHtmlToEpisodeModels(by: html, urlString: urlString)

        let expectingModel = EpisodeModel(
            episode: "Episode 190822",
            title: "Does your age affect your political views?",
            desc: "Age and political views",
            date: "22 Aug 2019".toDate(dateFormat: "dd MMM yyyy"),
            imagePath: "http://ichef.bbci.co.uk/images/ic/976xn/p07jtrrn.jpg",
            path: "/learningenglish/english/features/6-minute-english/ep-190822"
        )

        apiService.episodesReturnValue = .just(episodesModels)

        // Create a MockObserver<[EpisodeModel]>
        let episodes = scheduler.createObserver([EpisodeModel].self)

        // Output combines with the MockObserver(episodes above)
        sut.episodes
            .bind(to: episodes)
            .disposed(by: disposeBag)

        // MockObservable combines with Input
        scheduler
            .createColdObservable([
                .next(0, ()),
                .next(10, ()),
                .next(200, ())
            ])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(episodes.events.count, 3)

        let firstModel = episodes.events.first!.value.element!.first!
        XCTAssertEqual(firstModel, expectingModel)
    }

    func testRefreshing() {
        let refreshing = scheduler.createObserver(Bool.self)
        sut.refreshing
            .bind(to: refreshing)
            .disposed(by: disposeBag)

        scheduler
            .createColdObservable([
                .next(0, ()),
                .next(10, ())
            ])
            .bind(to: sut.initalLoad)
            .disposed(by: disposeBag)

        // execute reload.flatMapLatest by episodes.subscribe()
        sut.episodes
            .subscribe()
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(refreshing.events.count, 2)
        XCTAssertEqual(refreshing.events, [
            .next(0, true),
            .next(10, true)
        ])
    }

    func testShowEpisodeDetail() {
        var episode = "Episode 190815"
        var title = "Cryptocurrencies"
        var desc = "Libra, Bitcoin... would you invest in digital money?"
        var date = "15 Aug 2019".toDate(dateFormat: "dd MMM yyyy")
        var imagePath = "http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg"
        var path = "/learningenglish/english/features/6-minute-english/ep-190815"
        let episodeModel190815 = EpisodeModel(
            episode: episode,
            title: title,
            desc: desc,
            date: date,
            imagePath: imagePath,
            path: path
        )

        episode = "Episode 190822"
        title = "Does your age affect your political views?"
        desc = "Age and political views"
        date = "22 Aug 2019".toDate(dateFormat: "dd MMM yyyy")
        imagePath = ""
        path = "/learningenglish/english/features/6-minute-english/ep-190822"
        let episodeModel190822 = EpisodeModel(
            episode: episode,
            title: title,
            desc: desc,
            date: date,
            imagePath: imagePath,
            path: path
        )

        let showEpisodeDetail = scheduler.createObserver(EpisodeModel.self)
        sut.showEpisodeDetail
            .bind(to: showEpisodeDetail)
            .disposed(by: disposeBag)

        scheduler
            .createColdObservable([
                .next(10, episodeModel190815),
                .next(20, episodeModel190822)
            ])
            .bind(to: sut.selectEpisode)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(showEpisodeDetail.events.count, 2)
        XCTAssertEqual(showEpisodeDetail.events, [
            .next(10, episodeModel190815),
            .next(20, episodeModel190822)
        ])
    }

    func testShowVocabulary() {
        let showVocabulary = scheduler.createObserver(Void.self)
        sut.showVocabulary
            .bind(to: showVocabulary)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.tapVocabulary)
        .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(showVocabulary.events.count, 2)
    }

    func testGetCellViewModel() {
        let bundle = Bundle(for: type(of: self))
        let urlString = bundle.path(forResource: "6-minute-english", ofType: "html")!
        let url = URL(fileURLWithPath: urlString)
        let html = try! String(contentsOf: url)
        let episodesModels = ParseSixMinutesHelper().parseHtmlToEpisodeModels(by: html, urlString: urlString)
        apiService.episodesReturnValue = .just(episodesModels)

        sut.episodes
            .subscribe()
            .disposed(by: disposeBag)
        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)

        let setCellViewModel = scheduler.createObserver(EpisodeCellViewModel.self)
        sut.setCellViewModel
            .bind(to: setCellViewModel)
            .disposed(by: disposeBag)
        scheduler
            .createColdObservable([
                .next(200, 1),
                .next(300, 2)
            ])
            .bind(to: sut.getCellViewModel)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(setCellViewModel.events.count, 2)
    }

    func testInit_WithError() {
        let error = NSError(domain: "unit test", code: 2, userInfo: nil)
        let expectingModel = AlertModel(
            title: "Get Episode List Error",
            message: error.localizedDescription
        )
        apiService.episodesReturnValue = .error(error)

        let alert = scheduler.createObserver(AlertModel.self)
        sut.alert
            .bind(to: alert)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(300, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)

        // execute reload.flatMapLatest by episodes.subscribe()
        sut.episodes
            .subscribe()
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(alert.events.count, 1)
        XCTAssertEqual(alert.events, [.next(300, expectingModel)])
    }
}

// swiftlint:enable force_try
