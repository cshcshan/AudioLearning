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
        let viewController = EpisodeListViewController.initialize(from: "Episode", storyboardID: "EpisodeList")
        viewController.viewModel = viewModel
        navigationController = UINavigationController(rootViewController: viewController)
        
        viewModel.showVocabulary
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.showVocabulary(episode: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func showEpisodeDetail(apiService: APIService, episodeModel: EpisodeModel) {
        // ViewModel
        let realmService = RealmService<EpisodeDetailRealmModel>()
        let viewModel = EpisodeDetailViewModel(apiService: apiService,
                                               realmService: realmService,
                                               episodeModel: episodeModel)
        
        // Music and Vocabulary Detail
        let musicPlayerVC = newMusicPlayerVC()
        let vocabularyDetailVC = newVocabularyDetailVC(episodeDetailViewModel: viewModel)
        
        viewModel.audioLink
            .map({ (link) -> URL in
                guard let url = URL(string: link) else { throw Errors.urlIsNull }
                return url
            })
            .bind(to: musicPlayerVC.viewModel.settingNewAudio)
            .disposed(by: disposeBag)
        
        viewModel.shrinkMusicPlayer
            .subscribe(onNext: { (_) in
                musicPlayerVC.viewModel.changeSpeedSegmentedControlAlpha.onNext(0)
                musicPlayerVC.viewModel.changeSliderAlpha.onNext(0)
            })
            .disposed(by: disposeBag)
        
        viewModel.enlargeMusicPlayer
            .subscribe(onNext: { (_) in
                musicPlayerVC.viewModel.changeSpeedSegmentedControlAlpha.onNext(1)
                musicPlayerVC.viewModel.changeSliderAlpha.onNext(1)
            })
            .disposed(by: disposeBag)
        
        viewModel.showAddVocabularyDetail
            .subscribe(onNext: { (word) in
                vocabularyDetailVC.viewModel.addWithWord.onNext((episodeModel.episode, word))
            })
            .disposed(by: disposeBag)
        
        // ViewController
        let viewController = EpisodeDetailViewController.initialize(from: "Episode", storyboardID: "EpisodeDetail")
        viewController.viewModel = viewModel
        viewController.musicPlayerView = musicPlayerVC.view
        viewController.vocabularyDetailView = vocabularyDetailVC.view
        viewController.addChild(musicPlayerVC)
        viewController.addChild(vocabularyDetailVC)
        
        viewModel.showVocabulary
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.showVocabulary(episode: episodeModel.episode)
            })
            .disposed(by: disposeBag)
        
        vocabularyDetailVC.viewModel.alert
            .subscribe(onNext: { (alert) in
                viewController.showConfirmAlert(title: alert.title,
                                                message: alert.message,
                                                confirmHandler: nil,
                                                completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func newMusicPlayerVC() -> MusicPlayerViewController {
        let player = HCAudioPlayer()
        let musicPlayerViewModel = MusicPlayerViewModel(player: player)
        let viewController = MusicPlayerViewController.initialize(from: "MusicPlayer",
                                                                  storyboardID: "MusicPlayerViewController")
        viewController.viewModel = musicPlayerViewModel
        return viewController
    }
    
    private func newVocabularyDetailVC(episodeDetailViewModel: EpisodeDetailViewModel) -> VocabularyDetailViewController {
        // ViewModel
        let realmService = RealmService<VocabularyRealmModel>()
        let viewModel = VocabularyDetailViewModel(realmService: realmService)
        
        viewModel.close.map({ true })
            .bind(to: episodeDetailViewModel.hideVocabularyDetailView)
            .disposed(by: disposeBag)
        
        // ViewController
        let viewController = VocabularyDetailViewController.initialize(from: "Vocabulary",
                                                                       storyboardID: "VocabularyDetailViewController")
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    private func showVocabulary(episode: String?) {
        let vocabularyCoordinator = VocabularyCoordinator(navigationController: navigationController, episode: episode)
        _ = coordinate(to: vocabularyCoordinator)
    }
}
