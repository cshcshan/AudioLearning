//
//  APIService.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/31.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol APIServiceProtocol {
    // Inputs
    var loadEpisodes: AnyObserver<Void>! { get }
    var loadEpisodeDetail: AnyObserver<EpisodeModel>! { get }

    // Outputs
    var episodes: Observable<[EpisodeRealm]>! { get }
    var episodeDetail: Observable<EpisodeDetailRealm?>! { get }

    func getImage(path: String, completionHandler: @escaping (UIImage?) -> Void)
}

final class APIService: APIServiceProtocol {
    enum URLPath: String {
        case domain = "http://www.bbc.co.uk"
        case episodeList = "http://www.bbc.co.uk/learningenglish/english/features/6-minute-english"

        var url: URL? {
            URL(string: rawValue)
        }
    }

    // Inputs
    private(set) var loadEpisodes: AnyObserver<Void>!
    private(set) var loadEpisodeDetail: AnyObserver<EpisodeModel>!

    // Outputs
    private(set) var episodes: Observable<[EpisodeRealm]>!
    private(set) var episodeDetail: Observable<EpisodeDetailRealm?>!

    private var urlSession: URLSession
    private var parseSMHelper: ParseSixMinutesHelper

    private let disposeBag = DisposeBag()

    init(urlSession: URLSession = URLSession.shared, parseSMHelper: ParseSixMinutesHelper) {
        let configuration = urlSession.configuration
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 30
        self.urlSession = URLSession(configuration: configuration)
        self.parseSMHelper = parseSMHelper
        setupBindings()
    }

    private func setupBindings() {
        let loadEpisodesSubject = PublishSubject<Void>()
        loadEpisodes = loadEpisodesSubject.asObserver()

        let loadEpisodeDetailSubject = PublishSubject<EpisodeModel>()
        loadEpisodeDetail = loadEpisodeDetailSubject.asObserver()

        episodes = loadEpisodesSubject
            .flatMapLatest { [weak self] _ -> Observable<[EpisodeRealm]> in
                guard let self = self else { return .empty() }
                guard let url = URLPath.episodeList.url else {
                    return .error(Errors.urlIsNull)
                }
                let request = URLRequest(url: url)
                return self.urlSession.rx
                    .response(request: request)
                    .map { [weak self] (response: HTTPURLResponse, data: Data) -> [EpisodeRealm] in
                        guard let self = self else { return [] }
                        guard 200..<300 ~= response.statusCode else {
                            throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                        }
                        guard let html = String(data: data, encoding: .utf8) else {
                            throw Errors.convertDataToHtml
                        }
                        return self.parseSMHelper.parseHtmlToEpisodeModels(by: html, urlString: url.absoluteString)
                    }
            }

        episodeDetail = loadEpisodeDetailSubject
            .flatMapLatest { [weak self] episodeModel -> Observable<EpisodeDetailRealm?> in
                guard let self = self else { return .empty() }
                guard let episode = episodeModel.episode, let path = episodeModel.path else {
                    return .error(Errors.pathIsNull)
                }
                guard path.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                    return .error(Errors.pathIsNull)
                }
                guard let domain = URLPath.domain.url else {
                    return .error(Errors.urlIsNull)
                }
                let url = domain.appendingPathComponent(path)
                let request = URLRequest(url: url)
                return self.urlSession.rx
                    .response(request: request)
                    .map { [weak self] response, data -> EpisodeDetailRealm? in
                        guard 200..<300 ~= response.statusCode else {
                            throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                        }
                        guard let html = String(data: data, encoding: .utf8) else {
                            throw Errors.convertDataToHtml
                        }
                        let episodeDetailModel = self?.parseSMHelper.parseHtmlToEpisodeDetailModel(
                            by: html,
                            urlString: url.absoluteString,
                            episode: episode
                        )
                        return episodeDetailModel
                    }
            }
    }

    func getImage(path: String, completionHandler: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: path) else { return completionHandler(nil) }
        let request = URLRequest(url: url)
        urlSession.rx
            .response(request: request)
            .subscribe(onNext: { response, data in
                guard 200..<300 ~= response.statusCode else {
                    return completionHandler(nil)
                }
                completionHandler(UIImage(data: data))
            })
            .disposed(by: disposeBag)
    }
}
