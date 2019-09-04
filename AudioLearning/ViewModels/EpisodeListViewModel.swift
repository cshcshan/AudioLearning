//
//  EpisodeListViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/2.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EpisodeListViewModel {
    
    // Input
    private(set) var reload: PublishSubject<Void>
    
    // Output
    private(set) var episodes: Observable<[EpisodeModel]>
    private(set) var alert: Observable<AlertModel>
    private(set) var refreshing: Observable<Bool>
    
    private let apiService: APIServiceProtocol!
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        
        self.reload = PublishSubject<Void>().asObserver()
        
        let alertSubject = PublishSubject<AlertModel>()
        alert = alertSubject
        
        let refreshingSubject = PublishSubject<Bool>()
        refreshing = refreshingSubject
        
        self.episodes = reload.flatMapLatest({ (_) -> Observable<[EpisodeModel]> in
            refreshingSubject.onNext(true)
            return apiService.getEpisodes()
        }).catchError({ (error) -> Observable<[EpisodeModel]> in
            let alertModel = AlertModel(title: "Get Episode List Error",
                                        message: error.localizedDescription)
            alertSubject.onNext(alertModel)
            return .empty()
        })
    }
}
