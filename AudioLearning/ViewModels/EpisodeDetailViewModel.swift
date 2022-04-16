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

    // Inputs and Outputs
    private(set) var shrinkMusicPlayer = PublishSubject<Void>()
    private(set) var enlargeMusicPlayer = PublishSubject<Void>()
    private(set) var hideVocabularyDetailView = BehaviorSubject<Bool>(value: true)

    // Input
    private(set) var load: AnyObserver<Void>!
    private(set) var tapVocabulary: AnyObserver<Void>!
    private(set) var addVocabulary: AnyObserver<String>!

    // Output
    private(set) var title = ""
    private(set) var image = BehaviorSubject<UIImage?>(value: nil)
    private(set) var scriptHtml = BehaviorSubject<String>(value: "")
    private(set) var audioLink: Observable<String>!
    private(set) var alert: Observable<AlertModel>!
    private(set) var refreshing: Observable<Bool>!
    private(set) var showVocabulary: Observable<Void>!
    private(set) var showAddVocabularyDetail: Observable<String>!

    private let loadSubject = PublishSubject<Void>()
    private let tapVocabularySubject = PublishSubject<Void>()
    private let addVocabularySubject = PublishSubject<String>()
    private let alertSubject = PublishSubject<AlertModel>()
    private let refreshingSubject = PublishSubject<Bool>()

    private let apiService: APIServiceProtocol!
    private let realmService: RealmService<EpisodeDetailRealm>!
    private let episodeModel: EpisodeModel

    init(
        apiService: APIServiceProtocol,
        realmService: RealmService<EpisodeDetailRealm>,
        episodeModel: EpisodeModel
    ) {
        self.apiService = apiService
        self.realmService = realmService
        self.episodeModel = episodeModel
        super.init()

        if let imagePath = episodeModel.imagePath {
            apiService.getImage(path: imagePath) { [weak self] image in
                guard let self = self else { return }
                self.image.onNext(image)
            }
        } else {
            image.onNext(nil)
        }

        self.load = loadSubject.asObserver()
        self.tapVocabulary = tapVocabularySubject.asObserver()
        self.showVocabulary = tapVocabularySubject.asObservable()
        self.addVocabulary = addVocabularySubject.asObserver()
        self.showAddVocabularyDetail = addVocabularySubject.asObservable()
        self.title = episodeModel.title ?? ""
        self.alert = alertSubject
        self.refreshing = refreshingSubject

        showAddVocabularyDetail
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.hideVocabularyDetailView.onNext(false)
            })
            .disposed(by: disposeBag)

        reloadDataFromServer()
            .subscribe()
            .disposed(by: disposeBag)

        let loadEpisodeDetailModels = realmService.filterObjects
            .flatMapLatest { [weak self] episodeDetailRealms -> Observable<EpisodeDetailModel> in
                guard let self = self else { return .empty() }
                guard let model = episodeDetailRealms.first else {
                    self.refreshingSubject.onNext(true)
                    apiService.loadEpisodeDetail.onNext(episodeModel)
                    return .empty()
                }
                return .just(EpisodeDetailModel(scriptHtml: model.scriptHtml, audioLink: model.audioLink))
            }
            .take(1)
            .share() // use share() to avoid multiple subscriptions from the same Observable

        let episodeDetailModels = realmService.filterObjects
            .flatMapLatest { episodeDetailRealms -> Observable<EpisodeDetailModel> in
                guard let model = episodeDetailRealms.first else { return .empty() }
                return .just(EpisodeDetailModel(scriptHtml: model.scriptHtml, audioLink: model.audioLink))
            }
            .skip(1)
            .share() // use share() to avoid multiple subscriptions from the same Observable

        Observable.of(loadEpisodeDetailModels, episodeDetailModels)
            .merge()
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                self.refreshingSubject.onNext(false)
                self.scriptHtml.onNext(model.scriptHtml ?? "")
            })
            .disposed(by: disposeBag)

        self.audioLink = Observable.of(loadEpisodeDetailModels, episodeDetailModels)
            .merge()
            .map { model -> String in
                model.audioLink ?? ""
            }

        loadSubject
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.loadData()
            })
            .disposed(by: disposeBag)
    }

    private func reloadDataFromServer() -> Observable<Void> {
        apiService.episodeDetail
            .flatMapLatest { [weak self] episodeDetailRealm -> Observable<Void> in
                guard let self = self else { return .empty() }
                guard let episodeDetailRealm = episodeDetailRealm else { return .empty() }
                _ = self.realmService.add(object: episodeDetailRealm)
                self.loadData()
                self.refreshingSubject.onNext(false)
                return .empty()
            }
            .catch { [weak self] error -> Observable<Void> in
                guard let self = self else { return .empty() }
                self.refreshingSubject.onNext(false)
                let alertModel = AlertModel(
                    title: "Load Episode Detail Error",
                    message: error.localizedDescription
                )
                self.alertSubject.onNext(alertModel)
                return .empty()
            }
    }

    private func loadData() {
        guard let episode = episodeModel.episode else { return }
        let predicate = NSPredicate(format: "episode == %@", episode)
        realmService.filter.onNext((predicate, nil))
    }
}
