//
//  Network.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/30.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

protocol NetworkProtocol {
    typealias Handler = (Data?, URLResponse?, Error?) -> Void
    func performRequest(for url: URL, completionHandler: @escaping Handler)
}

extension URLSession: NetworkProtocol {
    typealias Handler = NetworkProtocol.Handler
    func performRequest(for url: URL, completionHandler: @escaping NetworkProtocol.Handler) {
        let task = dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
}

class Network {
    enum Result {
        case data(Data)
        case error(Error)
    }
    
    private let network: NetworkProtocol
    
    init(network: NetworkProtocol = URLSession.shared) {
        self.network = network
    }
    
    func get(from url: URL, completionHandler: @escaping (Result) -> Void) {
        network.performRequest(for: url) { (data, _, error) in
            if let error = error {
                return completionHandler(.error(error))
            }
            completionHandler(.data(data ?? Data()))
        }
    }
}
