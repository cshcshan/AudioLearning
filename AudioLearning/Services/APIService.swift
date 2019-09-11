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
    func getEpisodeDetail(path: String) -> Observable<EpisodeDetailModel>
}

class APIService: APIServiceProtocol {
    enum URLPath: String {
        case domain = "http://www.bbc.co.uk"
        case episodeList = "http://www.bbc.co.uk/learningenglish/english/features/6-minute-english"
        
        var url: URL? {
            return URL(string: self.rawValue)
        }
    }
    
    var urlSession: URLSession
    var parseSMHelper: ParseSixMinutesHelper
    
    init(urlSession: URLSession = URLSession.shared, parseSMHelper: ParseSixMinutesHelper) {
        self.urlSession = urlSession
        self.parseSMHelper = parseSMHelper
    }
    
    func getEpisodes() -> Observable<[EpisodeModel]> {
        guard let url = URLPath.episodeList.url else {
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
                let episodeModels = self?.parseSMHelper.parseHtmlToEpisodeModels(by: html, urlString: url.absoluteString)
                return episodeModels ?? []
        }
    }
    
    func getEpisodeDetail(path: String) -> Observable<EpisodeDetailModel> {
        guard path.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            return .error(Errors.pathIsNull)
        }
        guard let domain = URLPath.domain.url else {
            return .error(Errors.urlIsNull)
        }
        let url = domain.appendingPathComponent(path)
        let request = URLRequest(url: url)
        return urlSession.rx
            .response(request: request)
            .map { [weak self] (response, data) -> EpisodeDetailModel in
                guard 200..<300 ~= response.statusCode else {
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
                guard let html = String(data: data, encoding: .utf8) else {
                    throw Errors.convertDataToHtml
                }
                let episodeDetailModel = self?.parseSMHelper.parseHtmlToEpisodeDetailModel(by: html, urlString: url.absoluteString)
                return episodeDetailModel ?? EpisodeDetailModel(path: nil, scriptHtml: nil, audioLink: nil)
        }
    }
}
