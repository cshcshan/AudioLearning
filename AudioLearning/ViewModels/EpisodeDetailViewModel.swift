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
    private(set) var reload: PublishSubject<Void>
    
    // Output
    private(set) var title: String
    private(set) var scriptHtml: Observable<String>
    private(set) var audioLink: Observable<String>
    private(set) var alert: Observable<AlertModel>
    
    private let apiService: APIServiceProtocol!
    private let episodeModel: EpisodeModel
    
    private let disposeBag: DisposeBag!
    
    init(apiService: APIServiceProtocol, episodeModel: EpisodeModel) {
        self.apiService = apiService
        self.episodeModel = episodeModel
        
        self.disposeBag = DisposeBag()
        
        self.reload = PublishSubject<Void>().asObserver()
        
        self.title = episodeModel.title ?? ""
        
        let alertSubject = PublishSubject<AlertModel>()
        self.alert = alertSubject
        
        let episodeDetailModels = reload.flatMapLatest({ (_) in
            apiService.getEpisodeDetail(path: episodeModel.path ?? "")
        }).catchError({ (error) -> Observable<EpisodeDetailModel> in
            let alertModel = AlertModel(title: "Get Episode List Error",
                                        message: error.localizedDescription)
            alertSubject.onNext(alertModel)
            return .empty()
        })
        scriptHtml = episodeDetailModels.map({ (model) -> String in
            model.scriptHtml ?? ""
        })
        audioLink = episodeDetailModels.map({ (model) -> String in
            model.audioLink ?? ""
        })
    }
}
