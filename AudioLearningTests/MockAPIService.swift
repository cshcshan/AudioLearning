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
    private(set) var episodes: Observable<[EpisodeRealmModel]>!
    private(set) var episodeDetail: Observable<EpisodeDetailRealmModel?>!
    
    var episodesReturnValue: Observable<[EpisodeRealmModel]> = .empty()
    var episodeDetailReturnValue: Observable<EpisodeDetailRealmModel?> = .empty()
    private(set) var episodeDetailPath: String?
    
    init() {
        let loadEpisodesSubject = PublishSubject<Void>()
        loadEpisodes = loadEpisodesSubject.asObserver()
        
        let loadEpisodeDetailSubject = PublishSubject<EpisodeModel>()
        loadEpisodeDetail = loadEpisodeDetailSubject.asObserver()
        
        episodes = loadEpisodesSubject
            .flatMapLatest({ [weak self] (_) -> Observable<[EpisodeRealmModel]> in
                guard let `self` = self else { return .empty() }
                return self.episodesReturnValue
            })
        
        episodeDetail = loadEpisodeDetailSubject
            .flatMapLatest({ [weak self] (episodeModel) -> Observable<EpisodeDetailRealmModel?> in
                guard let `self` = self else { return .empty() }
                guard let episode = episodeModel.episode else { return .empty() }
                self.episodeDetailPath = episode
                return self.episodeDetailReturnValue
            })
    }
}
