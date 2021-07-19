//
//  EpisodeCellViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/21.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class EpisodeCellViewModel: BaseViewModel {

    struct Inputs {
        let load: AnyObserver<EpisodeModel>
    }

    // MARK: - Properties

    let inputs: Inputs
    
    // Outputs
    private(set) var title = BehaviorSubject<String>(value: "")
    private(set) var date = BehaviorSubject<String>(value: "")
    private(set) var desc = BehaviorSubject<String>(value: "")
    private(set) var image = BehaviorSubject<UIImage?>(value: nil)
    private(set) var imageRefreshing = BehaviorSubject<Bool>(value: false)
    
    private let load = PublishSubject<EpisodeModel>()
    
    private var apiService: APIServiceProtocol?
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        self.inputs = Inputs(load: load.asObserver())
        super.init()

        load.map { $0.title ?? "" }.bind(to: title).disposed(by: disposeBag)
        load.map { $0.desc ?? "" }.bind(to: desc).disposed(by: disposeBag)

        load
            .map {
                guard let date = $0.date, let dateString = date.toString(dateFormat: "yyyy/M/d") else { return "" }
                return dateString
            }
            .bind(to: date)
            .disposed(by: disposeBag)

        let imagePath = load
            .map { episode -> String? in
                guard let path = episode.imagePath else { return nil }
                return path
            }
            .share()

        imagePath.filter { $0 == nil }.map { _ in nil }.bind(to: image).disposed(by: disposeBag)
        imagePath
            .compactMap { $0 }
            .do(onNext: { [weak self] _ in
                self?.imageRefreshing.onNext(true)
            })
            .subscribe(with: self, onNext: { `self`, imagePath in
                apiService.getImage(path: imagePath) { image in
                    self.image.onNext(image)
                    self.imageRefreshing.onNext(false)
                }
            })
            .disposed(by: disposeBag)
    }
}
