//
//  ParseHelperTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
@testable import AudioLearning

class ParseHelperTests: XCTestCase {

    var sut: ParseHelper!

    override func setUp() {
        super.setUp()
        sut = ParseHelper()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testConvertHtmlToEpisodeModels() {
        // li.course-content-item
        guard let path = Bundle.main.path(forResource: "6-minute-english", ofType: "html") else {
            XCTFail("Cannot find the 6-minute-english.html file.")
            return
        }
        let url = URL(fileURLWithPath: path)
        guard let htmlString = try? String(contentsOf: url) else {
            XCTFail("Cannt get the content of 6-minute-english.html")
            return
        }
        let array = sut.convertHtmlToEpisodeModels(htmlString)
        XCTAssertEqual(array.count, 262)
    }
}
