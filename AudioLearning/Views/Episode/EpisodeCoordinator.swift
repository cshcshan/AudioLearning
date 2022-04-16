//
//  EpisodeCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import UIKit

final class EpisodeCoordinator: BaseCoordinator<Void> {

    private let window: UIWindow
    private var navigationController: UINavigationController!
    private var episodeDetailViewController: EpisodeDetailViewController?
    private var musicPlayerVC: MusicPlayerViewController?

    required init(window: UIWindow) {
        self.window = window
    }

    override func start() -> Observable<Void> {
        showEpisodeList()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return .empty()
    }

    private func showEpisodeList() {
        // ViewModel
        let parseSixMinutesHelper = ParseSixMinutesHelper()
        let apiService = APIService(parseSMHelper: parseSixMinutesHelper)
        let realmService = RealmService<EpisodeRealm>()
        let viewModel = EpisodeListViewModel(apiService: apiService, realmService: realmService)

        // Note:
        //   If didn't store childCoordinator to BaseCoordinator.childCoordinators,
        //   the observable 'showEpisodeDetail' from viewModel will be disposed at the end of AppCoordinator.
        viewModel.showEpisodeDetail
            .subscribe(onNext: { [weak self] episode in
                guard let self = self else { return }
                self.showEpisodeDetail(apiService: apiService, episode: episode)
            })
            .disposed(by: bag)

        // after pressing playingButton, display the episode detail which is playing audio
        viewModel.showEpisodeDetailFromPlaying
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showEpisodeDetailFromPlaying()
            })
            .disposed(by: bag)

        // ViewController
        let viewController = EpisodeListViewController.initialize(from: .episode, storyboardID: .episodeList)
        viewController.viewModel = viewModel
        navigationController = UINavigationController(rootViewController: viewController)

        viewModel.showVocabulary
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showVocabulary(episode: nil)
            })
            .disposed(by: bag)
    }

    private func showEpisodeDetail(apiService: APIService, episode: Episode) {
        // ViewModel
        let realmService = RealmService<EpisodeDetailRealm>()
        let viewModel = EpisodeDetailViewModel(
            apiService: apiService,
            realmService: realmService,
            episode: episode
        )

        // Music and Vocabulary Detail
        let musicPlayerVC = newOrGetMusicPlayerVC()
        let vocabularyDetailVC = newVocabularyDetailVC(episodeDetailViewModel: viewModel)

        viewModel.audioLink
            .map { link -> URL in
                guard let url = URL(string: link) else { throw Errors.urlIsNull }
                return url
            }
            .bind(to: musicPlayerVC.viewModel.settingNewAudio)
            .disposed(by: bag)

        viewModel.shrinkMusicPlayer
            .subscribe(onNext: { _ in
                musicPlayerVC.viewModel.changeSpeedSegmentedControlAlpha.onNext(0)
                musicPlayerVC.viewModel.changeSliderAlpha.onNext(0)
            })
            .disposed(by: bag)

        viewModel.enlargeMusicPlayer
            .subscribe(onNext: { _ in
                musicPlayerVC.viewModel.changeSpeedSegmentedControlAlpha.onNext(1)
                musicPlayerVC.viewModel.changeSliderAlpha.onNext(1)
            })
            .disposed(by: bag)

        viewModel.showAddVocabularyDetail
            .subscribe(onNext: { word in
                vocabularyDetailVC.viewModel.addWithWord.onNext((episode.id, word))
            })
            .disposed(by: bag)

        // ViewController
        let viewController = EpisodeDetailViewController.initialize(from: .episode, storyboardID: .episodeDetail)
        viewController.viewModel = viewModel
        viewController.musicPlayerView = musicPlayerVC.view
        viewController.vocabularyDetailView = vocabularyDetailVC.view
        viewController.addChild(musicPlayerVC)
        viewController.addChild(vocabularyDetailVC)

        viewModel.showVocabulary
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showVocabulary(episode: episode.id)
            })
            .disposed(by: bag)

        vocabularyDetailVC.viewModel.alert
            .subscribe(onNext: { alert in
                viewController.showConfirmAlert(
                    title: alert.title,
                    message: alert.message,
                    confirmHandler: nil,
                    completionHandler: nil
                )
            })
            .disposed(by: bag)

        episodeDetailViewController = viewController
        navigationController.pushViewController(viewController, animated: true)
    }

    private func newOrGetMusicPlayerVC() -> MusicPlayerViewController {
        if let musicPlayerVC = musicPlayerVC {
            musicPlayerVC.viewModel.reset.onNext(())
            musicPlayerVC.view.removeFromSuperview()
            musicPlayerVC.removeFromParent()
            return musicPlayerVC
        }

        let player = HCAudioPlayer()
        let musicPlayerViewModel = MusicPlayerViewModel(player: player)
        let viewController = MusicPlayerViewController.initialize(
            from: .musicPlayer,
            storyboardID: .musicPlayerViewController
        )
        viewController.viewModel = musicPlayerViewModel
        musicPlayerVC = viewController
        return viewController
    }

    private func newVocabularyDetailVC(episodeDetailViewModel: EpisodeDetailViewModel)
        -> VocabularyDetailViewController {
        // ViewModel
        let realmService = RealmService<VocabularyRealm>()
        let viewModel = VocabularyDetailViewModel(realmService: realmService)

        viewModel.close.map { true }
            .bind(to: episodeDetailViewModel.hideVocabularyDetailView)
            .disposed(by: bag)

        // ViewController
        let viewController = VocabularyDetailViewController.initialize(
            from: .vocabulary,
            storyboardID: .vocabularyDetailViewController
        )
        viewController.viewModel = viewModel

        return viewController
    }

    private func showVocabulary(episode: String?) {
        let vocabularyCoordinator = VocabularyCoordinator(navigationController: navigationController, episode: episode)
        _ = coordinate(to: vocabularyCoordinator)
    }

    private func showEpisodeDetailFromPlaying() {
        guard let viewController = episodeDetailViewController else { return }
        // FIXME: The detail view is incorrect with the audio
        navigationController.pushViewController(viewController, animated: true)
    }
}
