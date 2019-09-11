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
    private(set) var reload: AnyObserver<Void>
    private(set) var selectEpisode: AnyObserver<EpisodeModel>
    
    // Output
    private(set) var episodes: Observable<[EpisodeModel]>!
    private(set) var alert: Observable<AlertModel>
    private(set) var refreshing: Observable<Bool>
    private(set) var showEpisodeDetail: Observable<EpisodeModel>
    
    private let apiService: APIServiceProtocol!
    
    private let reloadSubject = PublishSubject<Void>()
    private let selectEpisodeSubject = PublishSubject<EpisodeModel>()
    private let alertSubject = PublishSubject<AlertModel>()
    private let refreshingSubject = PublishSubject<Bool>()
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        
        reload = reloadSubject.asObserver()
        selectEpisode = selectEpisodeSubject.asObserver()
        showEpisodeDetail = selectEpisodeSubject.asObservable()
        alert = alertSubject.asObservable()
        refreshing = refreshingSubject.asObservable()
        
        episodes = reloadData()
    }
    
    private func reloadData() -> Observable<[EpisodeModel]> {
        return reloadSubject
            .flatMapLatest({ [weak self] (_) -> Observable<[EpisodeModel]> in
                guard let `self` = self else { return .empty() }
                self.refreshingSubject.onNext(true)
                return self.apiService.getEpisodes()
            }).catchError({ [weak self] (error) -> Observable<[EpisodeModel]> in
                guard let `self` = self else { return .empty() }
                self.refreshingSubject.onNext(false)
                let alertModel = AlertModel(title: "Get Episode List Error",
                                            message: error.localizedDescription)
                self.alertSubject.onNext(alertModel)
                return self.reloadData()
            })
    }
}
