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
    private(set) var episodeDetail: Observable<EpisodeDetailRealm?>!
    private(set) var error: Observable<Error>!

    var episodesReturnValue: Observable<[EpisodeRealm]> = .empty()
    var episodeDetailReturnValue: Observable<EpisodeDetailRealm?> = .empty()
    private(set) var episodeDetailPath: String?

    init() {
        let loadEpisodesSubject = PublishSubject<Void>()
        self.loadEpisodes = loadEpisodesSubject.asObserver()

        let loadEpisodeDetailSubject = PublishSubject<Episode>()
        self.loadEpisodeDetail = loadEpisodeDetailSubject.asObserver()

        let loadResultEvent = loadEpisodesSubject
            .flatMapLatest { [weak self] _ -> Observable<Event<[EpisodeRealm]>> in
                guard let self = self else { return .empty() }
                return self.episodesReturnValue.materialize()
            }
            .share()

        self.episodes = loadResultEvent.map(\.element).compactMap { $0 }
        self.error = loadResultEvent.map(\.error).compactMap { $0 }

        self.episodeDetail = loadEpisodeDetailSubject
            .flatMapLatest { [weak self] episode -> Observable<EpisodeDetailRealm?> in
                guard let self = self, let id = episode.id else { return .empty() }
                self.episodeDetailPath = id
                return self.episodeDetailReturnValue
            }
    }

    func getImage(path: String, completionHandler: @escaping (UIImage?) -> Void) {
        completionHandler(nil)
    }
}
