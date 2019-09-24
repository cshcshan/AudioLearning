//
//  EpisodeCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift

class EpisodeCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private var navigationController: UINavigationController!
    
    required init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        self.showEpisodeList()
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
        return .never()
    }
    
    private func showEpisodeList() {
        // ViewModel
        let parseSixMinutesHelper = ParseSixMinutesHelper()
        let apiService = APIService(parseSMHelper: parseSixMinutesHelper)
        let realmService = RealmService<EpisodeRealmModel>()
        let viewModel = EpisodeListViewModel(apiService: apiService, realmService: realmService)
        
        /*
         Note:
            If didn't store childCoordinator to BaseCoordinator.childCoordinators,
            the observable 'showEpisodeDetail' from viewModel will be disposed at the end of AppCoordinator.
         */
        viewModel.showEpisodeDetail
            .subscribe(onNext: { [weak self] (episodeModel) in
                guard let `self` = self else { return }
                self.showEpisodeDetail(apiService: apiService, episodeModel: episodeModel)
            })
            .disposed(by: disposeBag)
        
        // ViewController
        let episodeListViewController = EpisodeListViewController.initialize(from: "Episode", storyboardID: "EpisodeList")
        episodeListViewController.viewModel = viewModel
        navigationController = UINavigationController(rootViewController: episodeListViewController)
        
        viewModel.showVocabulary
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.showVocabulary(on: episodeListViewController)
            })
            .disposed(by: disposeBag)
    }
    
    private func showEpisodeDetail(apiService: APIService, episodeModel: EpisodeModel) {
        // MusicViewModel and ViewController
        let player = HCAudioPlayer()
        let musicPlayerViewModel = MusicPlayerViewModel(player: player)
        let musicPlayerViewController = MusicPlayerViewController.initialize(from: "MusicPlayer", storyboardID: "MusicPlayerViewController")
        musicPlayerViewController.viewModel = musicPlayerViewModel
        
        // ViewModel
        let realmService = RealmService<EpisodeDetailRealmModel>()
        let viewModel = EpisodeDetailViewModel(apiService: apiService, realmService: realmService, episodeModel: episodeModel)
        
        viewModel.audioLink
            .map({ (link) -> URL in
                guard let url = URL(string: link) else { throw Errors.urlIsNull }
                return url
            })
            .bind(to: musicPlayerViewModel.settingNewAudio)
            .disposed(by: disposeBag)
        
        // ViewController
        let episodeDetailViewController = EpisodeDetailViewController.initialize(from: "Episode", storyboardID: "EpisodeDetail")
        episodeDetailViewController.viewModel = viewModel
        episodeDetailViewController.musicPlayerViewController = musicPlayerViewController
        navigationController.pushViewController(episodeDetailViewController, animated: true)
    }
    
    private func showVocabulary(on rootViewController: UIViewController) {
        let vocabularyCoordinator = VocabularyCoordinator(navigationController: navigationController)
        _ = coordinate(to: vocabularyCoordinator)
    }
}
