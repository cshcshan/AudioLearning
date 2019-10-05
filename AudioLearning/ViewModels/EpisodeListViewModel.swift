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

class EpisodeListViewModel: BaseViewModel {
    
    // Input
    private(set) var initalLoad: AnyObserver<Void>!
    private(set) var reload: AnyObserver<Void>!
    private(set) var selectEpisode: AnyObserver<EpisodeModel>!
    private(set) var tapVocabulary: AnyObserver<Void>!
    
    // Output
    private(set) var episodes: Observable<[EpisodeModel]>!
    private(set) var alert: Observable<AlertModel>!
    private(set) var refreshing: Observable<Bool>!
    private(set) var showEpisodeDetail: Observable<EpisodeModel>!
    private(set) var showVocabulary: Observable<Void>!
    
    private let initalLoadSubject = PublishSubject<Void>()
    private let reloadSubject = PublishSubject<Void>()
    private let selectEpisodeSubject = PublishSubject<EpisodeModel>()
    private let tapVocabularySubject = PublishSubject<Void>()
    private let alertSubject = PublishSubject<AlertModel>()
    private let refreshingSubject = PublishSubject<Bool>()
    
    private let apiService: APIServiceProtocol!
    private let realmService: RealmService<EpisodeRealmModel>!
    
    init(apiService: APIServiceProtocol, realmService: RealmService<EpisodeRealmModel>) {
        self.apiService = apiService
        self.realmService = realmService
        super.init()
        
        initalLoad = initalLoadSubject.asObserver()
        reload = reloadSubject.asObserver()
        selectEpisode = selectEpisodeSubject.asObserver()
        showEpisodeDetail = selectEpisodeSubject.asObservable()
        tapVocabulary = tapVocabularySubject.asObserver()
        showVocabulary = tapVocabularySubject.asObservable()
        alert = alertSubject.asObservable()
        refreshing = refreshingSubject.asObservable()
        
        reloadDataFromServer()
            .subscribe()
            .disposed(by: disposeBag)
        
        episodes = realmService.allObjects
            .flatMapLatest({ (episodeRealmModels) -> Observable<[EpisodeModel]> in
                var episodeModels = [EpisodeModel]()
                for episodeRealmModel in episodeRealmModels {
                    let episodeModel = EpisodeModel(episode: episodeRealmModel.episode,
                                                    title: episodeRealmModel.title,
                                                    desc: episodeRealmModel.desc,
                                                    date: episodeRealmModel.date,
                                                    imagePath: episodeRealmModel.imagePath,
                                                    path: episodeRealmModel.path)
                    episodeModels.append(episodeModel)
                }
                return .just(episodeModels)
            })
        
        initalLoadSubject
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.loadData()
                self.refreshingSubject.onNext(true)
                apiService.loadEpisodes.onNext(())
            })
            .disposed(by: disposeBag)
        
        reloadSubject
            .subscribe(onNext: { (_) in
                apiService.loadEpisodes.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    private func reloadDataFromServer() -> Observable<Void> {
        return apiService.episodes
            .flatMapLatest({ [weak self] (episodeRealmModels) -> Observable<Void> in
                guard let `self` = self else { return .empty() }
                _ = self.realmService.add(objects: episodeRealmModels)
                self.loadData()
                self.refreshingSubject.onNext(false)
                return .empty()
            })
            .catchError({ [weak self] (error) -> Observable<Void> in
                guard let `self` = self else { return .empty() }
                self.refreshingSubject.onNext(false)
                let alertModel = AlertModel(title: "Get Episode List Error",
                                            message: error.localizedDescription)
                self.alertSubject.onNext(alertModel)
                return self.reloadDataFromServer()
            })
    }
    
    private func loadData() {
        realmService.loadAll.onNext(["episode": false])
    }
}
