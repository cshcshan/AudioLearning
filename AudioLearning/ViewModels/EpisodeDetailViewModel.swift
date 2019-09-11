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
    private(set) var scriptHtml: BehaviorSubject<String>
    private(set) var audioLink: Observable<String>
    private(set) var alert: Observable<AlertModel>
    private(set) var refreshing: Observable<Bool>
    
    private let apiService: APIServiceProtocol!
    private let episodeModel: EpisodeModel
    
    private let disposeBag: DisposeBag!
    
    init(apiService: APIServiceProtocol, episodeModel: EpisodeModel) {
        self.apiService = apiService
        self.episodeModel = episodeModel
        
        self.disposeBag = DisposeBag()
        
        let reloadSubject = PublishSubject<Void>()
        self.reload = reloadSubject.asObserver()
        
        self.title = episodeModel.title ?? ""
        
        let alertSubject = PublishSubject<AlertModel>()
        self.alert = alertSubject
        
        let refreshingSubject = PublishSubject<Bool>()
        self.refreshing = refreshingSubject
        
        let episodeDetailModels = reloadSubject.flatMapLatest({ (_) -> Observable<EpisodeDetailModel> in
            refreshingSubject.onNext(true)
            return apiService.getEpisodeDetail(path: episodeModel.path ?? "")
        }).catchError({ (error) -> Observable<EpisodeDetailModel> in
            refreshingSubject.onNext(false)
            let alertModel = AlertModel(title: "Load Episode Detail Error",
                                        message: error.localizedDescription)
            alertSubject.onNext(alertModel)
            return .empty()
        })
        
        let scriptHtmlSubject = BehaviorSubject<String>(value: "")
        scriptHtml = scriptHtmlSubject
        episodeDetailModels
            .subscribe(onNext: { (model) in
                scriptHtmlSubject.onNext(model.scriptHtml ?? "")
            })
            .disposed(by: disposeBag)
        
        audioLink = episodeDetailModels.map({ (model) -> String in
            model.audioLink ?? ""
        })
    }
}
