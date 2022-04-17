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

final class EpisodeCellViewModelTests: XCTestCase {

    var apiService: APIServiceProtocol!
    var episode190815: Episode!
    var episode190822: Episode!
    var episodeNil: Episode!

    var scheduler: TestScheduler!
    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        episode190815 = Episode(
            id: "Episode 190815",
            title: "Cryptocurrencies",
            desc: "Libra, Bitcoin... would you invest in digital money?",
            date: "15 Aug 2019".date(withDateFormat: "dd MMM yyyy"),
            imagePath: "http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg",
            path: "/learningenglish/english/features/6-minute-english/ep-190815"
        )
        episode190822 = Episode(
            id: "Episode 190822",
            title: "Does your age affect your political views?",
            desc: "Age and political views",
            date: "22 Aug 2019".date(withDateFormat: "dd MMM yyyy"),
            imagePath: "http://ichef.bbci.co.uk/images/ic/976xn/p07jtrrn.jpg",
            path: "/learningenglish/english/features/6-minute-english/ep-190822"
        )
        episodeNil = Episode()
        apiService = MockAPIService()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        apiService = nil
        super.tearDown()
    }

    func testTitle() {
        let sut1 = EpisodeCellViewModel(apiService: apiService, episode: episode190815)
        let sut2 = EpisodeCellViewModel(apiService: apiService, episode: episode190822)
        let sut3 = EpisodeCellViewModel(apiService: apiService, episode: episodeNil)

        XCTAssertEqual(sut1.title, "Cryptocurrencies")
        XCTAssertEqual(sut2.title, "Does your age affect your political views?")
        XCTAssertEqual(sut3.title, nil)
    }

    func testDate() {
        let sut1 = EpisodeCellViewModel(apiService: apiService, episode: episode190815)
        let sut2 = EpisodeCellViewModel(apiService: apiService, episode: episode190822)
        let sut3 = EpisodeCellViewModel(apiService: apiService, episode: episodeNil)

        XCTAssertEqual(sut1.date, "2019/8/15")
        XCTAssertEqual(sut2.date, "2019/8/22")
        XCTAssertEqual(sut3.date, nil)
    }

    func testDesc() {
        let sut1 = EpisodeCellViewModel(apiService: apiService, episode: episode190815)
        let sut2 = EpisodeCellViewModel(apiService: apiService, episode: episode190822)
        let sut3 = EpisodeCellViewModel(apiService: apiService, episode: episodeNil)

        XCTAssertEqual(sut1.desc, "Libra, Bitcoin... would you invest in digital money?")
        XCTAssertEqual(sut2.desc, "Age and political views")
        XCTAssertEqual(sut3.desc, nil)
    }
}
