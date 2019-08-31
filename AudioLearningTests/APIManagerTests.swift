//
//  APIManagerTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/8/31.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
@testable import AudioLearning

class APIManagerTests: XCTestCase {
    
    var sut: APIManager!
    var network: Network!
    var urlSession: MockURLSession!

    override func setUp() {
        urlSession = MockURLSession()
        network = Network(urlSession: urlSession)
        sut = APIManager(network: network)
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        network = nil
        urlSession = nil
        super.tearDown()
    }
    
    func testGetEpisodeListData() {
        let url = URL(string: "http://www.bbc.co.uk/learningenglish/english/features/6-minute-english")!
        var result: Network.Result?
        sut.getEpisodeList { result = $0 }
        XCTAssertEqual(urlSession.url, url)
        XCTAssertNotEqual(result, Network.Result.error(nil))
    }
}
