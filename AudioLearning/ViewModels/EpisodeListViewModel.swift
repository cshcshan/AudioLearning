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
    private(set) var reload: AnyObserver<Void>!
    private(set) var selectEpisode: AnyObserver<EpisodeModel>!
    
    // Output
    private(set) var episodes: Observable<[EpisodeModel]>!
    private(set) var alert: Observable<AlertModel>!
    private(set) var refreshing: Observable<Bool>!
    private(set) var showEpisodeDetail: Observable<EpisodeModel>!
    
    private let apiService: APIServiceProtocol!
    
    private let reloadSubject = PublishSubject<Void>()
    private let selectEpisodeSubject = PublishSubject<EpisodeModel>()
    private let alertSubject = PublishSubject<AlertModel>()
    private let refreshingSubject = PublishSubject<Bool>()
    
    private let disposeBag = DisposeBag()
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        
        reload = reloadSubject.asObserver()
        selectEpisode = selectEpisodeSubject.asObserver()
        showEpisodeDetail = selectEpisodeSubject.asObservable()
        alert = alertSubject.asObservable()
        refreshing = refreshingSubject.asObservable()
        
        episodes = reloadData()
        
        reloadSubject
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.refreshingSubject.onNext(true)
                apiService.loadEpisodes.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    private func reloadData() -> Observable<[EpisodeModel]> {
        return apiService.episodes
            .flatMapLatest({ (episodeRealmModels) -> Observable<[EpisodeModel]> in
                var episodeModels = [EpisodeModel]()
                guard let models = RealmService.shared.add(objects: episodeRealmModels) else {
                    return Observable.just(episodeModels)
                }
                for model in models {
                    let model = EpisodeModel(episode: model.episode, title: model.title, desc: model.desc, date: model.date, imagePath: model.imagePath, path: model.path)
                    episodeModels.append(model)
                }
                return Observable.just(episodeModels)
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
