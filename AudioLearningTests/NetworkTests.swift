//
//  NetworkTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/8/31.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
@testable import AudioLearning

class NetworkTests: XCTestCase {
    
    var sut: Network!
    var urlSession: MockURLSession!
    
    override func setUp() {
        urlSession = MockURLSession()
        sut = Network(urlSession: urlSession)
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        urlSession = nil
        super.tearDown()
    }
    
    func testGetMethod() {
        let url = URL(string: "https://www.hanchen.com")!
        let expectingResult = Network.Result.data("MockURLSession".data(using: .utf8)!)
        var result: Network.Result?
        sut.get(from: url) { result = $0 }
        XCTAssertEqual(urlSession.url, url)
        XCTAssertEqual(result, expectingResult)
    }
    
    func testGetMethod_WithErrorResult() {
        let url = URL(string: "https://www.hanchen.com")!
        var result: Network.Result?
        sut.get(from: url) { result = $0 }
        XCTAssertEqual(urlSession.url, url)
        XCTAssertNotEqual(result, Network.Result.error(nil))
    }
}
