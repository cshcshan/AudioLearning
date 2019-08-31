//
//  APIService.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/31.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

class APIService {
    enum URLPath: String {
        case episodeList = "http://www.bbc.co.uk/learningenglish/english/features/6-minute-english"
    }
    
    var network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func getEpisodeList(completionHandler: @escaping (Network.Result) -> Void) {
        guard let url = URL(string: URLPath.episodeList.rawValue) else {
            return completionHandler(.error(Errors.urlIsNull))
        }
        network.get(from: url, completionHandler: completionHandler)
    }
}
