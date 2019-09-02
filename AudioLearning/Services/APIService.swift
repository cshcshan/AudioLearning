//
//  APIService.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/31.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol APIServiceProtocol {
    func getEpisodes() -> Observable<[EpisodeModel]>
}

class APIService {
    enum URLPath: String {
        case episodeList = "http://www.bbc.co.uk/learningenglish/english/features/6-minute-english"
    }
    
    var urlSession: URLSession
    var parseSMHelper: ParseSixMinutesHelper
    
    init(urlSession: URLSession = URLSession.shared, parseSMHelper: ParseSixMinutesHelper) {
        self.urlSession = urlSession
        self.parseSMHelper = parseSMHelper
    }
    
    func getEpisodes() -> Observable<[EpisodeModel]> {
        let urlString = URLPath.episodeList.rawValue
        guard let url = URL(string: urlString) else {
            return .error(Errors.urlIsNull)
        }
        let request = URLRequest(url: url)
        return urlSession.rx
            .response(request: request)
            .map { [weak self] (response: HTTPURLResponse, data: Data) -> [EpisodeModel] in
                guard 200..<300 ~= response.statusCode else {
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
                guard let html = String(data: data, encoding: .utf8) else {
                    throw Errors.convertDataToHtml
                }
                let episodeModels = self?.parseSMHelper.parseHtmlToEpisodeModels(by: html, urlString: urlString)
                return episodeModels ?? []
        }
    }
}
