//
//  EpisodeCellViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/21.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxSwift

final class EpisodeCellViewModel: BaseViewModel {
    
    // Inputs
    private(set) var load: AnyObserver<EpisodeModel?>!
    
    // Outputs
    private(set) var title = BehaviorSubject<String>(value: "")
    private(set) var date = BehaviorSubject<String>(value: "")
    private(set) var desc = BehaviorSubject<String>(value: "")
    private(set) var image = BehaviorSubject<UIImage?>(value: nil)
    private(set) var imageRefreshing = BehaviorSubject<Bool>(value: false)
    
    private let loadSubject = PublishSubject<EpisodeModel?>()
    
    private var apiService: APIServiceProtocol?
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        super.init()
        load = loadSubject.asObserver()
        
        loadSubject
            .subscribe(onNext: { [weak self] (episodeModel) in
                guard let self = self else { return }
                guard let episodeModel = episodeModel else {
                    self.title.onNext("")
                    self.date.onNext("")
                    self.desc.onNext("")
                    return
                }
                self.title.onNext(episodeModel.title ?? "")
                if let dateVal = episodeModel.date, let dateValStr = dateVal.toString(dateFormat: "yyyy/M/d") {
                    self.date.onNext(dateValStr)
                } else {
                    self.date.onNext("")
                }
                self.desc.onNext(episodeModel.desc ?? "")
                if let imagePath = episodeModel.imagePath {
                    self.imageRefreshing.onNext(true)
                    apiService.getImage(path: imagePath, completionHandler: { [weak self] (image) in
                        guard let self = self else { return }
                        self.image.onNext(image)
                        self.imageRefreshing.onNext(false)
                    })
                } else {
                    self.image.onNext(nil)
                }
            })
            .disposed(by: disposeBag)
    }
}
