//
//  ExtensionStringTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
@testable import AudioLearning

class ExtensionStringTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testToDate_WithddMMMMyyyy() {
        let sut = String("15 Aug 2019")
        let date = sut.toDate(dateFormat: "dd MMM yyyy")
        XCTAssertNotNil(date)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2019
        dateComponents.month = 8
        dateComponents.day = 15
        let expectaing = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual(date, expectaing)
    }
}
