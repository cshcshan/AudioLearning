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
        let link = ""
        let scriptHtml = ""
        let audioLink = ""
        let sut = EpisodeDetailModel(link: link, scriptHtml: scriptHtml, audioLink: audioLink)
        XCTAssertEqual(sut.link, link)
        XCTAssertEqual(sut.scriptHtml, scriptHtml)
        XCTAssertEqual(sut.audioLink, audioLink)
    }
    
    func testInit_WithNil() {
        let sut = EpisodeDetailModel(link: nil, scriptHtml: nil, audioLink: nil)
        XCTAssertNil(sut.link)
        XCTAssertNil(sut.scriptHtml)
        XCTAssertNil(sut.audioLink)
    }
}
