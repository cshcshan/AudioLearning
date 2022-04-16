//
//  AlertModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/2.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
@testable import AudioLearning

class AlertModelTestsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let title = "Han"
        let message = "Hell World!"
        let sut = AlertModel(title: title, message: message)
        XCTAssertEqual(sut.title, title)
        XCTAssertEqual(sut.message, message)
    }

    func testInit_WithNil() {
        let sut = AlertModel(title: nil, message: nil)
        XCTAssertNil(sut.title)
        XCTAssertNil(sut.message)
    }
}
