//
//  EpisodeListViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/2.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class EpisodeListViewModel: BaseViewModel {

    struct State {
        let cellViewModels: Driver<[EpisodeCellViewModel]>
        let isRefreshing: Driver<Bool>
    }

    struct Event {
        let fetchDataWithIsFirstTime = PublishRelay<Bool>()
        let episodeSelected = PublishRelay<Int>()
        let episodeSelectedWithData = PublishRelay<Episode>()
        let vocabularyTapped = PublishRelay<Void>()
        let showAlert = PublishRelay<AlertModel>()
    }

    // MARK: - Properties

    let state: State
    let event = Event()

    // Output
    private let cellViewModels = BehaviorRelay<[EpisodeCellViewModel]>(value: [])
    private let isRefreshing = BehaviorRelay<Bool>(value: false)

    private let apiService: APIServiceProtocol!
    private let realmService: RealmService<EpisodeRealm>!

    private var episodes: [Episode] = []

    init(apiService: APIServiceProtocol, realmService: RealmService<EpisodeRealm>) {
        self.apiService = apiService
        self.realmService = realmService

        self.state = State(
            cellViewModels: cellViewModels.asDriver(onErrorJustReturn: []),
            isRefreshing: isRefreshing.asDriver()
        )

        super.init()

        // API bindings

        apiService.episodes
            .flatMapLatest { [weak self] episodeRealms in
                self?.realmService.add(objects: episodeRealms) ?? .empty()
            }
            .subscribe(with: self, onNext: { `self`, _ in
                self.fetchDataFromLocalDB()
            })
            .disposed(by: bag)

        apiService.fetchEpisodesError
            .map { error in AlertModel(title: "Get Episode List Error", message: error.localizedDescription) }
            .bind(to: event.showAlert)
            .disposed(by: bag)

        Observable
            .merge([apiService.episodes.map { _ in }, apiService.fetchEpisodesError.map { _ in }])
            .map { _ in false }
            .observe(on: MainScheduler.instance)
            .bind(to: isRefreshing)
            .disposed(by: bag)

        // DB bindings

        realmService.state.allItems
            .map { [weak self] episodeRealms in
                self?.episodes = []
                return episodeRealms.map { episodeRealm in
                    let episode = Episode(from: episodeRealm)
                    self?.episodes.append(episode)
                    return EpisodeCellViewModel(apiService: apiService, episode: episode)
                }
            }
            .bind(to: cellViewModels)
            .disposed(by: bag)

        // Events bindings

        let isFirstTimeFetchData = event.fetchDataWithIsFirstTime.filter { $0 }.share()
        isFirstTimeFetchData.map { _ in true }.bind(to: isRefreshing).disposed(by: bag)
        isFirstTimeFetchData
            .map { _ in }
            .do(onNext: { [weak self] in self?.fetchDataFromLocalDB() })
            .bind(to: apiService.loadEpisodes)
            .disposed(by: bag)

        event.fetchDataWithIsFirstTime.filter { !$0 }.map { _ in }.bind(to: apiService.loadEpisodes).disposed(by: bag)

        event.episodeSelected
            .compactMap { [weak self] index -> Episode? in
                guard let self = self, self.episodes.indices.contains(index) else { return nil }
                return self.episodes[index]
            }
            .bind(to: event.episodeSelectedWithData)
            .disposed(by: bag)
    }

    // MARK: - Helpers

    private func fetchDataFromLocalDB() {
        realmService.event.loadAll.accept([RealmSortField(fieldName: "id", isAscending: false)])
    }
}
