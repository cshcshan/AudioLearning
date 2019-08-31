//
//  Network.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/30.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
    typealias Handler = (Data?, URLResponse?, Error?) -> Void
    func performRequest(for url: URL, completionHandler: @escaping Handler)
}

extension URLSession: URLSessionProtocol {
    typealias Handler = URLSessionProtocol.Handler
    func performRequest(for url: URL, completionHandler: @escaping URLSessionProtocol.Handler) {
        let task = dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
}

class Network {
    enum Result: Equatable {
        case data(Data?)
        case error(Error?)
        
        static func == (lhs: Network.Result, rhs: Network.Result) -> Bool {
            switch (lhs, rhs) {
            case (let .data(lhsData), let .data(rhsData)):
                return lhsData == rhsData
            case (.error(_), .error(_)):
                return true
            default:
                return false
            }
        }
    }
    
    private let urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func get(from url: URL, completionHandler: @escaping (Result) -> Void) {
        urlSession.performRequest(for: url) { (data, _, error) in
            if let error = error {
                return completionHandler(.error(error))
            }
            completionHandler(.data(data ?? Data()))
        }
    }
}
