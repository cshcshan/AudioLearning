//
//  EpisodeDetailModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/8/30.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
@testable import AudioLearning

class EpisodeDetailModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let scriptHtml = "<div></div>"
        let audioLink =
            "http://downloads.bbc.co.uk/learningenglish/features/6min/190815_6min_english_cryptocurrency_download.mp3"
        let sut = EpisodeDetailModel(scriptHtml: scriptHtml, audioLink: audioLink)
        XCTAssertEqual(sut.scriptHtml, scriptHtml)
        XCTAssertEqual(sut.audioLink, audioLink)
    }

    func testInit_WithNil() {
        let sut = EpisodeDetailModel(scriptHtml: nil, audioLink: nil)
        XCTAssertNil(sut.scriptHtml)
        XCTAssertNil(sut.audioLink)
    }
}
