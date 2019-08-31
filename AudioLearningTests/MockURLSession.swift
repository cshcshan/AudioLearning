//
//  MockNetwork.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/8/30.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
@testable import AudioLearning

class MockURLSession: URLSessionProtocol {
    typealias Handler = URLSessionProtocol.Handler
    
    var url: URL?
    
    func performRequest(for url: URL, completionHandler: @escaping Handler) {
        self.url = url
        let data = "MockURLSession".data(using: .utf8)
        completionHandler(data, nil, nil)
    }
}
