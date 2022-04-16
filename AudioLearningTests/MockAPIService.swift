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
    private(set) var loadEpisodeDetail: AnyObserver<EpisodeModel>!
    private(set) var episodes: Observable<[EpisodeRealm]>!
    private(set) var episodeDetail: Observable<EpisodeDetailRealm?>!

    var episodesReturnValue: Observable<[EpisodeRealm]> = .empty()
    var episodeDetailReturnValue: Observable<EpisodeDetailRealm?> = .empty()
    private(set) var episodeDetailPath: String?

    init() {
        let loadEpisodesSubject = PublishSubject<Void>()
        self.loadEpisodes = loadEpisodesSubject.asObserver()

        let loadEpisodeDetailSubject = PublishSubject<EpisodeModel>()
        self.loadEpisodeDetail = loadEpisodeDetailSubject.asObserver()

        self.episodes = loadEpisodesSubject
            .flatMapLatest { [weak self] _ -> Observable<[EpisodeRealm]> in
                guard let self = self else { return .empty() }
                return self.episodesReturnValue
            }

        self.episodeDetail = loadEpisodeDetailSubject
            .flatMapLatest { [weak self] episodeModel -> Observable<EpisodeDetailRealm?> in
                guard let self = self else { return .empty() }
                guard let episode = episodeModel.episode else { return .empty() }
                self.episodeDetailPath = episode
                return self.episodeDetailReturnValue
            }
    }

    func getImage(path: String, completionHandler: @escaping (UIImage?) -> Void) {
        completionHandler(nil)
    }
}
