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

    struct Outputs {
        let title: Driver<String?>
        let date: Driver<String?>
        let desc: Driver<String?>
        let image: Driver<UIImage?>
        let imageRefreshing: Signal<Bool>
    }

    // MARK: - Properties

    let inputs: Inputs
    let outputs: Outputs
    
    private let load = PublishSubject<EpisodeModel>()

    private let title = BehaviorRelay<String?>(value: nil)
    private let date = BehaviorRelay<String?>(value: nil)
    private let desc = BehaviorRelay<String?>(value: nil)
    private let image = BehaviorRelay<UIImage?>(value: nil)
    private let imageRefreshing = PublishRelay<Bool>()
    
    private var apiService: APIServiceProtocol?
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        self.inputs = Inputs(load: load.asObserver())
        self.outputs = Outputs(
            title: title.asDriver(),
            date: date.asDriver(),
            desc: desc.asDriver(),
            image: image.asDriver(),
            imageRefreshing: imageRefreshing.asSignal())

        super.init()

        load.map { $0.title }.bind(to: title).disposed(by: disposeBag)
        load.map { $0.desc }.bind(to: desc).disposed(by: disposeBag)

        load.map { $0.date?.toString(dateFormat: "yyyy/M/d") }
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
                self?.imageRefreshing.accept(true)
            })
            .subscribe(with: self, onNext: { `self`, imagePath in
                apiService.getImage(path: imagePath) { image in
                    self.image.accept(image)
                    self.imageRefreshing.accept(false)
                }
            })
            .disposed(by: disposeBag)
    }
}
