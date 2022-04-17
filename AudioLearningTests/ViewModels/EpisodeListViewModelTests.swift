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
final class EpisodeListViewModelTests: XCTestCase {

    var sut: EpisodeListViewModel!
    var apiService: MockAPIService!
    var realmService: RealmService<EpisodeRealm>!

    var scheduler: TestScheduler!
    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "unit-testing-db"
        apiService = MockAPIService()
        realmService = RealmService()
        sut = EpisodeListViewModel(apiService: apiService, realmService: realmService)
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        apiService = nil
        super.tearDown()
    }

    func test_episodes() {
        let bundle = Bundle(for: type(of: self))
        let urlString = bundle.path(forResource: "6-minute-english", ofType: "html")!
        let url = URL(fileURLWithPath: urlString)
        let html = try! String(contentsOf: url)
        let episodesModels = ParseSixMinutesHelper().parseHtmlToEpisodeModels(by: html, urlString: urlString)

        let expectingModel = Episode(
            id: "Episode 190822",
            title: "Does your age affect your political views?",
            desc: "Age and political views",
            date: "22 Aug 2019".date(withDateFormat: "dd MMM yyyy"),
            imagePath: "http://ichef.bbci.co.uk/images/ic/976xn/p07jtrrn.jpg",
            path: "/learningenglish/english/features/6-minute-english/ep-190822"
        )

        apiService.episodesReturnValue = .just(episodesModels)

        // Create a MockObserver<[EpisodeModel]>
        let cellViewModels = scheduler.createObserver([EpisodeCellViewModel].self)

        // Output combines with the MockObserver(cellViewModels above)
        sut.state.cellViewModels.drive(cellViewModels).disposed(by: bag)

        // MockObservable combines with Input
        scheduler
            .createColdObservable([
                .next(0, false),
                .next(10, false),
                .next(200, false)
            ])
            .bind(to: sut.event.fetchDataWithIsFirstTime)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(cellViewModels.events.count, 4)

        let secondModel = cellViewModels.events[1].value.element!.first!
        XCTAssertEqual(secondModel.title, expectingModel.title)
        XCTAssertEqual(secondModel.desc, expectingModel.desc)
        XCTAssertEqual(secondModel.date, "2019/8/22")
    }

    func test_isRefreshing() {
        let isRefreshing = scheduler.createObserver(Bool.self)
        sut.state.isRefreshing.drive(isRefreshing).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(0, true),
                .next(10, true)
            ])
            .bind(to: sut.event.fetchDataWithIsFirstTime)
            .disposed(by: bag)

        // execute reload.flatMapLatest by cellViewModels.subscribe()
        sut.state.cellViewModels.drive().disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isRefreshing.events.count, 3)
        XCTAssertEqual(isRefreshing.events, [
            .next(0, false),
            .next(0, true),
            .next(10, true)
        ])
    }

    func test_init_withError() {
        let error = NSError(domain: "unit test", code: 100, userInfo: nil)
        let expectingModel = AlertModel(
            title: "Get Episode List Error",
            message: error.localizedDescription
        )
        apiService.episodesReturnValue = .error(error)

        let alert = scheduler.createObserver(AlertModel.self)
        sut.event.showAlert.bind(to: alert).disposed(by: bag)

        scheduler.createColdObservable([.next(300, false)])
            .bind(to: sut.event.fetchDataWithIsFirstTime)
            .disposed(by: bag)

        // execute reload.flatMapLatest by cellViewModels.subscribe()
        sut.state.cellViewModels.drive().disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(alert.events.count, 1)
        XCTAssertEqual(alert.events, [.next(300, expectingModel)])
    }

    func test_init_withConsecutiveError() {
        let error = NSError(domain: "unit test", code: 101, userInfo: nil)
        let expectingModel = AlertModel(
            title: "Get Episode List Error",
            message: error.localizedDescription
        )
        apiService.episodesReturnValue = .error(error)

        let alert = scheduler.createObserver(AlertModel.self)
        sut.event.showAlert.bind(to: alert).disposed(by: bag)

        scheduler.createColdObservable([.next(300, false), .next(500, false)])
            .bind(to: sut.event.fetchDataWithIsFirstTime)
            .disposed(by: bag)

        // execute reload.flatMapLatest by cellViewModels.subscribe()
        sut.state.cellViewModels
            .drive().disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(alert.events.count, 2)
        XCTAssertEqual(alert.events, [.next(300, expectingModel), .next(500, expectingModel)])
    }
}

// swiftlint:enable force_try
