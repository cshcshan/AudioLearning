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
}

extension ExtensionStringTests {
    
    // MARK: testToDate
    
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
    
    func testToDate_WithEmptyDateFormat() {
        let sut = String("15 Aug 2019")
        let date = sut.toDate(dateFormat: "")
        XCTAssertNil(date)
    }
    
    func testToDate_WithEmptyString() {
        let sut = String("")
        let date = sut.toDate(dateFormat: "dd MMM yyyy")
        XCTAssertNil(date)
    }
    
    func testToDate_WithWeirdDateFormat() {
        let sut = String("15 Aug 2019")
        let date = sut.toDate(dateFormat: "Hello")
        XCTAssertNil(date)
    }
}

extension ExtensionStringTests {
    
    // MARK: convertHtmlToNSAttributedString
    
    // swiftlint:disable line_length
    func testConvertHtmlToNSAttributedString() {
        let html = "<!DOCTYPE html><html><body><h1>This is heading 1</h1><h2>This is heading 2</h2><h3>This is heading 3</h3><h4>This is heading 4</h4><h5>This is heading 5</h5><h6>This is heading 6</h6></body></html>"
        let expectaing = "This is heading 1\nThis is heading 2\nThis is heading 3\nThis is heading 4\nThis is heading 5\nThis is heading 6\n"
        let result = html.convertHtml().string
        XCTAssertEqual(result, expectaing)
    }
    
    func testConvertHtmlToNSAttributedString_WithStyle() {
        let html = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.<br/><br/>Vivamus quis varius lorem, ut ultrices metus. Vestibulum ultricies neque lorem, id sollicitudin justo aliquam vel. Nullam imperdiet mauris ex.<br/><br/><b>Open Links:</b><br/><br/>*Google: <a href=\"http://www.google.com\">Google</a><br/><br/>*Apple: <a href=\"https://www.apple.com\">https://www.apple.com</a><br/>*Facebook: <a href=\"https://www.facebook.com\">Click me</a><br/><br/><b>Display phone numbers:</b><br/><br/>*Phone Numbers: <a href=\"tel:+7137860\">555-345-1234 123</a><br/>*Phone Text: <a href=\"tel:+7137860\">Emegency number</a><br/><br/><b>Open maps app:</b><br/><br/>*Go to Taipei 101: <a href=\"https://goo.gl/maps/EUss57T5nk42\">Taipei 101</a><br/>*Addresses: <a href=\"https://goo.gl/maps/EUss57T5nk42\">No. 7信義路五段 Xinyi District Taipei City, 110</a>;"
        let expectaing = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\nVivamus quis varius lorem, ut ultrices metus. Vestibulum ultricies neque lorem, id sollicitudin justo aliquam vel. Nullam imperdiet mauris ex.\n\nOpen Links:\n\n*Google: Google\n\n*Apple: https://www.apple.com\n*Facebook: Click me\n\nDisplay phone numbers:\n\n*Phone Numbers: 555-345-1234 123\n*Phone Text: Emegency number\n\nOpen maps app:\n\n*Go to Taipei 101: Taipei 101\n*Addresses: No. 7信義路五段 Xinyi District Taipei City, 110;"
        let result = html.convertHtml().string
        XCTAssertEqual(result, expectaing)
    }
    // swiftlint:enable line_length
}
