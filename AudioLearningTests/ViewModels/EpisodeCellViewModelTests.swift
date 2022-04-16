//
//  EpisodeCellViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/10/21.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import RxTest
import XCTest
@testable import AudioLearning

class EpisodeCellViewModelTests: XCTestCase {

    var sut: EpisodeCellViewModel!
    var apiService: APIServiceProtocol!
    var episodeModel190815: EpisodeModel!
    var episodeModel190822: EpisodeModel!
    var episodeModelNil: EpisodeModel!

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        episodeModel190815 = EpisodeModel(
            episode: "Episode 190815",
            title: "Cryptocurrencies",
            desc: "Libra, Bitcoin... would you invest in digital money?",
            date: "15 Aug 2019".toDate(dateFormat: "dd MMM yyyy"),
            imagePath: "http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg",
            path: "/learningenglish/english/features/6-minute-english/ep-190815"
        )
        episodeModel190822 = EpisodeModel(
            episode: "Episode 190822",
            title: "Does your age affect your political views?",
            desc: "Age and political views",
            date: "22 Aug 2019".toDate(dateFormat: "dd MMM yyyy"),
            imagePath: "http://ichef.bbci.co.uk/images/ic/976xn/p07jtrrn.jpg",
            path: "/learningenglish/english/features/6-minute-english/ep-190822"
        )
        episodeModelNil = EpisodeModel(episode: nil, title: nil, desc: nil, date: nil, imagePath: nil, path: nil)
        apiService = MockAPIService()
        sut = EpisodeCellViewModel(apiService: apiService)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        apiService = nil
        super.tearDown()
    }

    func testTitle() {
        let title = scheduler.createObserver(String?.self)
        sut.outputs.title.drive(title).disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(10, episodeModel190815),
            .next(20, episodeModel190822),
            .next(30, episodeModelNil)
        ])
        .bind(to: sut.inputs.load)
        .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(title.events.count, 4)
        XCTAssertEqual(title.events, [
            .next(0, nil),
            .next(10, "Cryptocurrencies"),
            .next(20, "Does your age affect your political views?"),
            .next(30, nil)
        ])
    }

    func testDate() {
        let date = scheduler.createObserver(String?.self)
        sut.outputs.date.drive(date).disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(10, episodeModel190815),
            .next(20, episodeModel190822),
            .next(30, episodeModelNil)
        ])
        .bind(to: sut.inputs.load)
        .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(date.events.count, 4)
        XCTAssertEqual(date.events, [
            .next(0, nil),
            .next(10, "2019/8/15"),
            .next(20, "2019/8/22"),
            .next(30, nil)
        ])
    }

    func testDesc() {
        let desc = scheduler.createObserver(String?.self)
        sut.outputs.desc.drive(desc).disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(10, episodeModel190815),
            .next(20, episodeModel190822),
            .next(30, episodeModelNil)
        ])
        .bind(to: sut.inputs.load)
        .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(desc.events.count, 4)
        XCTAssertEqual(desc.events, [
            .next(0, nil),
            .next(10, "Libra, Bitcoin... would you invest in digital money?"),
            .next(20, "Age and political views"),
            .next(30, nil)
        ])
    }
}
