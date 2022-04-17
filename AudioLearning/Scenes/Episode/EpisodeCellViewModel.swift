//
//  EpisodeCellViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/21.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class EpisodeCellViewModel: BaseViewModel {

    struct Outputs {
        let image: Driver<UIImage?>
        let imageRefreshing: Signal<Bool>
    }

    // MARK: - Properties

    let outputs: Outputs

    let title: String?
    let date: String?
    let desc: String?

    private let image = BehaviorRelay<UIImage?>(value: nil)
    private let imageRefreshing = PublishRelay<Bool>()

    private var apiService: APIServiceProtocol?

    init(apiService: APIServiceProtocol, episode: Episode) {
        self.apiService = apiService
        self.title = episode.title
        self.date = episode.date?.string(withDateFormat: "yyyy/M/d")
        self.desc = episode.desc
        self.outputs = Outputs(
            image: image.asDriver(),
            imageRefreshing: imageRefreshing.asSignal()
        )

        super.init()

        if let imagePath = episode.imagePath {
            imageRefreshing.accept(true)
            apiService.getImage(path: imagePath) { [weak self] image in
                self?.image.accept(image)
                self?.imageRefreshing.accept(false)
            }
        } else {
            image.accept(nil)
        }
    }
}
