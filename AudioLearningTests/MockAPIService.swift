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
    
    init() {}
    
    var episodesReturnValue: Observable<[EpisodeModel]> = .empty()
    var episodeDetailReturnValue: Observable<EpisodeDetailModel> = .empty()
    private(set) var episodeDetailPath: String?
    
    func getEpisodes() -> Observable<[EpisodeModel]> {
        return episodesReturnValue
    }
    
    func getEpisodeDetail(path: String) -> Observable<EpisodeDetailModel> {
        self.episodeDetailPath = path
        return episodeDetailReturnValue
    }
}
