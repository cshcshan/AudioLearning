//
//  EpisodeDetailViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/3.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift

final class EpisodeDetailViewModel: BaseViewModel {

    struct State {
        let isRefreshing: Driver<Bool>
        let image: Driver<UIImage?>
        let scriptHtmlString: Driver<String>
        let audioURLString: Driver<String>
        let isVocabularyDetailViewHidden = BehaviorRelay<Bool>(value: true)
    }

    struct Event {
        let fetchData = PublishRelay<Void>()
        let vocabularyTapped = PublishRelay<Void>()
        let addVocabularyTapped = PublishRelay<String>()
        let showAlert = PublishRelay<AlertModel>()
        let shrinkAudioPlayer = PublishRelay<Void>()
        let enlargeAudioPlayer = PublishRelay<Void>()
    }

    // MARK: - Properties

    let state: State
    let event = Event()

    let title: String

    private let image = BehaviorRelay<UIImage?>(value: nil)
    private let scriptHtmlString = BehaviorRelay<String>(value: "")
    private let audioURLString = BehaviorRelay<String>(value: "")
    private let isRefreshing = BehaviorRelay<Bool>(value: false)

    private let apiService: APIServiceProtocol!
    private let realmService: RealmService<EpisodeDetailRealm>!
    private let episode: Episode

    init(
        apiService: APIServiceProtocol,
        realmService: RealmService<EpisodeDetailRealm>,
        episode: Episode
    ) {
        self.apiService = apiService
        self.realmService = realmService
        self.episode = episode
        self.title = episode.title ?? ""

        self.state = State(
            isRefreshing: isRefreshing.asDriver(),
            image: image.asDriver(),
            scriptHtmlString: scriptHtmlString.asDriver(),
            audioURLString: audioURLString.asDriver()
        )

        super.init()

        // API bindings

        let apiEpisodeDetail = apiService.episodeDetail.share()
        let apiError = apiService.fetchEpisodeDetailError.share()

        apiEpisodeDetail
            .compactMap { $0 }
            .flatMapLatest { [weak self] episodeDetailRealm in
                self?.realmService.add(object: episodeDetailRealm) ?? .empty()
            }
            .subscribe(with: self, onNext: { `self`, _ in
                self.fetchDataFromLocalDB()
            })
            .disposed(by: bag)

        apiError
            .map { error in AlertModel(title: "Get Episode Detail Error", message: error.localizedDescription) }
            .bind(to: event.showAlert)
            .disposed(by: bag)

        Observable
            .merge([apiEpisodeDetail.map { _ in }, apiError.map { _ in }])
            .map { _ in false }
            .bind(to: isRefreshing)
            .disposed(by: bag)

        if let imagePath = episode.imagePath {
            apiService.getImage(path: imagePath) { [weak self] image in
                self?.image.accept(image)
            }
        } else {
            image.accept(nil)
        }

        // DB bindings

        let filterItem = realmService.state.filterItems.map(\.first).share()

        let episodeDetail = filterItem
            .compactMap { $0 }
            .map { EpisodeDetail(scriptHtml: $0.scriptHtml, audioLink: $0.audioLink) }
            .share()

        episodeDetail.map { _ in false }.bind(to: isRefreshing).disposed(by: bag)
        episodeDetail.map { $0.scriptHtml ?? "" }.bind(to: scriptHtmlString).disposed(by: bag)
        episodeDetail.map { $0.audioLink ?? "" }.bind(to: audioURLString).disposed(by: bag)

        // Events bindings

        event.addVocabularyTapped.asSignal()
            .map { _ in false }
            .emit(to: state.isVocabularyDetailViewHidden)
            .disposed(by: bag)

        event.fetchData.map { _ in episode }.bind(to: apiService.loadEpisodeDetail).disposed(by: bag)
    }

    private func fetchDataFromLocalDB() {
        guard let episode = episode.id else { return }
        let predicate = NSPredicate(format: "id == %@", episode)
        let filter = RealmFilter(predicate: predicate, sortFields: [])
        realmService.event.filter.accept(filter)
    }
}
