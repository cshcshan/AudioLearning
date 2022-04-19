//
//  MockAPIService.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/1.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxSwift
@testable import AudioLearning

class MockAPIService: APIServiceProtocol {

    private(set) var loadEpisodes: AnyObserver<Void>!
    private(set) var loadEpisodeDetail: AnyObserver<Episode>!
    private(set) var episodes: Observable<[EpisodeRealm]>!
    private(set) var fetchEpisodesError: Observable<Error>!
    private(set) var episodeDetail: Observable<EpisodeDetailRealm?>!
    private(set) var fetchEpisodeDetailError: Observable<Error>!

    var episodesReturnValue: Observable<[EpisodeRealm]> = .empty()
    var episodeDetailReturnValue: Observable<EpisodeDetailRealm?> = .empty()
    private(set) var episodeDetailPath: String?

    init() {
        let loadEpisodesSubject = PublishSubject<Void>()
        self.loadEpisodes = loadEpisodesSubject.asObserver()

        let loadEpisodeDetailSubject = PublishSubject<Episode>()
        self.loadEpisodeDetail = loadEpisodeDetailSubject.asObserver()

        let loadEpisodesResultEvent = loadEpisodesSubject
            .flatMapLatest { [weak self] _ -> Observable<Event<[EpisodeRealm]>> in
                guard let self = self else { return .empty() }
                return self.episodesReturnValue.materialize()
            }
            .share()

        self.episodes = loadEpisodesResultEvent.map(\.element).compactMap { $0 }
        self.fetchEpisodesError = loadEpisodesResultEvent.map(\.error).compactMap { $0 }

        let loadEpisodeDetailResultEvent = loadEpisodeDetailSubject
            .flatMapLatest { [weak self] episode -> Observable<Event<EpisodeDetailRealm?>> in
                guard let self = self, let id = episode.id else { return .empty() }
                self.episodeDetailPath = id
                return self.episodeDetailReturnValue.materialize()
            }
            .share()

        self.episodeDetail = loadEpisodeDetailResultEvent.map(\.element).compactMap { $0 }
        self.fetchEpisodeDetailError = loadEpisodeDetailResultEvent.map(\.error).compactMap { $0 }
    }

    func getImage(path: String, completionHandler: @escaping (UIImage?) -> Void) {
        completionHandler(nil)
    }
}
