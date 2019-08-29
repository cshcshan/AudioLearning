//
//  EpisodeModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
@testable import AudioLearning

class EpisodeModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        let episode = "Episode 190815"
        let title = "Cryptocurrencies"
        let desc = "Libra, Bitcoin... would you invest in digital money?"
        let date = "15 Aug 2019".toDate(dateFormat: "dd MMM yyyy")
        let imagePath = "http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg"
        let sut = EpisodeModel(episode: episode, title: title, desc: desc, date: date, imagePath: imagePath)
        XCTAssertEqual(sut.episode, episode)
        XCTAssertEqual(sut.title, title)
        XCTAssertEqual(sut.desc, desc)
        XCTAssertEqual(sut.date, date)
        XCTAssertEqual(sut.imagePath, imagePath)
    }
}
