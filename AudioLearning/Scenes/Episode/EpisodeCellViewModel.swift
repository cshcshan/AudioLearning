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

    struct State {
        let image: Driver<UIImage?>
        let isImageRefreshing: Driver<Bool>
    }

    // MARK: - Properties

    let state: State

    let title: String?
    let date: String?
    let desc: String?

    private let image = BehaviorRelay<UIImage?>(value: nil)
    private let isImageRefreshing = BehaviorRelay<Bool>(value: false)

    private var apiService: APIServiceProtocol?

    init(apiService: APIServiceProtocol, episode: Episode) {
        self.apiService = apiService
        self.title = episode.title
        self.date = episode.date?.string(withDateFormat: "yyyy/M/d")
        self.desc = episode.desc
        self.state = State(image: image.asDriver(), isImageRefreshing: isImageRefreshing.asDriver())

        super.init()

        if let imagePath = episode.imagePath {
            isImageRefreshing.accept(true)
            apiService.getImage(path: imagePath) { [weak self] image in
                self?.image.accept(image)
                self?.isImageRefreshing.accept(false)
            }
        } else {
            image.accept(nil)
        }
    }
}
