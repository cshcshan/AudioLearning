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
    private(set) var alert: PublishSubject<AlertModel>
    
    private let apiService: APIServiceProtocol!
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        
        self.reload = PublishSubject<Void>().asObserver()
        
        let alertSubject = PublishSubject<AlertModel>()
        alert = alertSubject
        
        self.episodes = reload.flatMapLatest { (_) in
            apiService.getEpisodes()
                .catchError { (error) -> Observable<[EpisodeModel]> in
                    let alertModel = AlertModel(title: "Get Episode List Error",
                                                message: error.localizedDescription)
                    alertSubject.onNext(alertModel)
                    return .empty()
                }
        }
    }
}
