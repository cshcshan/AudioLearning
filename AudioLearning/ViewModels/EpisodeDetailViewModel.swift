//
//  EpisodeDetailViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/3.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import RxCocoa

class EpisodeDetailViewModel {
    
    // Input
    private(set) var reload: AnyObserver<Void>
    
    // Output
    private(set) var title: String
    private(set) var scriptHtml = BehaviorSubject<String>(value: "")
    private(set) var audioLink: Observable<String>!
    private(set) var alert: Observable<AlertModel>
    private(set) var refreshing: Observable<Bool>
    
    private let apiService: APIServiceProtocol!
    private let episodeModel: EpisodeModel
    
    private let reloadSubject = PublishSubject<Void>()
    private let alertSubject = PublishSubject<AlertModel>()
    private let refreshingSubject = PublishSubject<Bool>()
    
    private let disposeBag = DisposeBag()
    
    init(apiService: APIServiceProtocol, episodeModel: EpisodeModel) {
        self.apiService = apiService
        self.episodeModel = episodeModel
        
        reload = reloadSubject.asObserver()
        title = episodeModel.title ?? ""
        alert = alertSubject
        refreshing = refreshingSubject
        
        let episodeDetailModels = apiService.episodeDetail
            .flatMapLatest({ (episodeDetailRealmModel) -> Observable<EpisodeDetailModel> in
                guard let episodeDetailRealmModel = episodeDetailRealmModel else { return .empty() }
                let model = RealmService.shared.add(object: episodeDetailRealmModel)
                let episodeDetailModel = EpisodeDetailModel(path: model?.path, scriptHtml: model?.scriptHtml, audioLink: model?.audioLink)
                return Observable.just(episodeDetailModel)
            })
            .catchError({ [weak self] (error) -> Observable<EpisodeDetailModel> in
                guard let `self` = self else { return .empty() }
                self.refreshingSubject.onNext(false)
                let alertModel = AlertModel(title: "Load Episode Detail Error",
                                            message: error.localizedDescription)
                self.alertSubject.onNext(alertModel)
                return .empty()
            })
            .share() // use share() to avoid multiple subscriptions from the same Observable

        episodeDetailModels
            .subscribe(onNext: { [weak self] (model) in
                guard let scriptHtml = self?.scriptHtml else { return }
                scriptHtml.onNext(model.scriptHtml ?? "")
            })
            .disposed(by: disposeBag)
        
        audioLink = episodeDetailModels
            .map({ (model) -> String in
                model.audioLink ?? ""
            })
        
        reloadSubject
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.refreshingSubject.onNext(true)
                apiService.loadEpisodeDetail.onNext(episodeModel.path ?? "")
            })
            .disposed(by: disposeBag)
    }
}
