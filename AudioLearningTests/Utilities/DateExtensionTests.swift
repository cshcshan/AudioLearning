//
//  DateExtensionTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
@testable import AudioLearning

final class DateExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
}

extension DateExtensionTests {

    // NARK: testToString

    func testToString_WithyMd() {
        var dateComponents = DateComponents()
        dateComponents.year = 2019
        dateComponents.month = 8
        dateComponents.day = 15
        let date = Calendar.current.date(from: dateComponents)

        XCTAssertEqual(date?.string(withDateFormat: "y/M/d"), "2019/8/15")
    }

    func testToString_WithEmptyDateFormat() {
        var dateComponents = DateComponents()
        dateComponents.year = 2019
        dateComponents.month = 8
        dateComponents.day = 15
        let date = Calendar.current.date(from: dateComponents)
        XCTAssertEqual(date?.string(withDateFormat: ""), "")
    }
}
