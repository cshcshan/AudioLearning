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

    // Input
    private(set) var initalLoad: AnyObserver<Void>!
    private(set) var reload: AnyObserver<Void>!
    private(set) var selectEpisode: AnyObserver<EpisodeModel>!
    private(set) var selectIndexPath: AnyObserver<IndexPath>!
    private(set) var getCellViewModel: AnyObserver<Int>!
    private(set) var tapVocabulary: AnyObserver<Void>!

    // Output
    private(set) var episodes: Observable<[EpisodeModel]>!
    private(set) var alert: Observable<AlertModel>!
    private(set) var refreshing: Observable<Bool>!
    private(set) var showEpisodeDetail: Observable<EpisodeModel>!
    private(set) var getSelectEpisodeCell: Observable<IndexPath>!
    private(set) var setCellViewModel: Observable<EpisodeCellViewModel>!
    private(set) var showVocabulary: Observable<Void>!

    private let initalLoadSubject = PublishSubject<Void>()
    private let reloadSubject = PublishSubject<Void>()
    private let selectEpisodeSubject = PublishSubject<EpisodeModel>()
    private let selectIndexPathSubject = PublishSubject<IndexPath>()
    private let getCellViewModelSubject = PublishSubject<Int>()
    private let tapVocabularySubject = PublishSubject<Void>()
    private let alertSubject = PublishSubject<AlertModel>()
    private let refreshingSubject = PublishSubject<Bool>()

    private let apiService: APIServiceProtocol!
    private let realmService: RealmService<EpisodeRealm>!
    private var cellViewModels: [EpisodeCellViewModel?]!

    init(apiService: APIServiceProtocol, realmService: RealmService<EpisodeRealm>) {
        self.apiService = apiService
        self.realmService = realmService
        super.init()

        self.initalLoad = initalLoadSubject.asObserver()
        self.reload = reloadSubject.asObserver()
        self.selectEpisode = selectEpisodeSubject.asObserver()
        self.selectIndexPath = selectIndexPathSubject.asObserver()
        self.getSelectEpisodeCell = selectIndexPathSubject.asObservable()
        self.showEpisodeDetail = selectEpisodeSubject.asObservable()
        self.getCellViewModel = getCellViewModelSubject.asObserver()
        self.tapVocabulary = tapVocabularySubject.asObserver()
        self.showVocabulary = tapVocabularySubject.asObservable()
        self.alert = alertSubject.asObservable()
        self.refreshing = refreshingSubject.asObservable()

        reloadDataFromServer()
            .subscribe()
            .disposed(by: bag)

        self.episodes = realmService.allObjects
            .flatMapLatest { [weak self] episodeRealms -> Observable<[EpisodeModel]> in
                guard let self = self else { return .empty() }
                var episodeModels = [EpisodeModel]()
                for episodeRealm in episodeRealms {
                    let episodeModel = EpisodeModel(from: episodeRealm)
                    episodeModels.append(episodeModel)
                }
                self.cellViewModels = [EpisodeCellViewModel?](repeating: nil, count: episodeModels.count)
                return .just(episodeModels)
            }

        initalLoadSubject
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.loadData()
                self.refreshingSubject.onNext(true)
                apiService.loadEpisodes.onNext(())
            })
            .disposed(by: bag)

        reloadSubject
            .subscribe(onNext: { _ in
                apiService.loadEpisodes.onNext(())
            })
            .disposed(by: bag)

        self.setCellViewModel = getCellViewModelSubject
            .flatMapLatest { [weak self] index -> Observable<EpisodeCellViewModel> in
                guard let self = self else { return .empty() }
                var cellViewModel = self.cellViewModels[index]
                if cellViewModel == nil {
                    cellViewModel = EpisodeCellViewModel(apiService: apiService)
                }
                self.cellViewModels[index] = cellViewModel
                return .just(cellViewModel!)
            }
    }

    private func reloadDataFromServer() -> Observable<Void> {
        apiService.episodes
            .flatMapLatest { [weak self] episodeRealms -> Observable<Void> in
                guard let self = self else { return .empty() }
                _ = self.realmService.add(objects: episodeRealms)
                self.loadData()
                self.refreshingSubject.onNext(false)
                return .empty()
            }
            .catch { [weak self] error -> Observable<Void> in
                guard let self = self else { return .empty() }
                self.refreshingSubject.onNext(false)
                let alertModel = AlertModel(
                    title: "Get Episode List Error",
                    message: error.localizedDescription
                )
                self.alertSubject.onNext(alertModel)
                return self.reloadDataFromServer()
            }
    }

    private func loadData() {
        realmService.loadAll.onNext(["id": false])
    }
}
