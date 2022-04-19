//
//  EpisodeCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import UIKit

final class EpisodeCoordinator: Coordinator<Void> {

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

        viewModel.event.episodeSelectedWithData.asSignal()
            .emit(with: self, onNext: { `self`, episode in
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

        viewModel.event.vocabularyTapped
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] _ in self?.showVocabulary(episodeID: nil) ?? .empty() }
            .subscribe()
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

        viewModel.state.audioURLString
            .compactMap(URL.init)
            .drive(musicPlayerVC.viewModel.settingNewAudio)
            .disposed(by: bag)

        viewModel.event.shrinkAudioPlayer.asSignal()
            .map { _ in 0 }
            .emit(
                to: musicPlayerVC.viewModel.changeSpeedSegmentedControlAlpha,
                musicPlayerVC.viewModel.changeSliderAlpha
            )
            .disposed(by: bag)

        viewModel.event.enlargeAudioPlayer.asSignal()
            .map { _ in 1 }
            .emit(
                to: musicPlayerVC.viewModel.changeSpeedSegmentedControlAlpha,
                musicPlayerVC.viewModel.changeSliderAlpha
            )
            .disposed(by: bag)

        viewModel.event.addVocabularyTapped
            .map { word in (episode.id, word) }
            .bind(to: vocabularyDetailVC.viewModel.addWithWord)
            .disposed(by: bag)

        // ViewController
        let viewController = EpisodeDetailViewController.initialize(from: .episode, storyboardID: .episodeDetail)
        viewController.viewModel = viewModel
        viewController.musicPlayerView = musicPlayerVC.view
        viewController.vocabularyDetailView = vocabularyDetailVC.view
        viewController.addChild(musicPlayerVC)
        viewController.addChild(vocabularyDetailVC)

        viewModel.event.vocabularyTapped
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] _ in self?.showVocabulary(episodeID: episode.id) ?? .empty() }
            .subscribe()
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
            .bind(to: episodeDetailViewModel.state.isVocabularyDetailViewHidden)
            .disposed(by: bag)

        // ViewController
        let viewController = VocabularyDetailViewController.initialize(
            from: .vocabulary,
            storyboardID: .vocabularyDetailViewController
        )
        viewController.viewModel = viewModel

        return viewController
    }

    private func showVocabulary(episodeID: String?) -> Observable<Void> {
        let vocabularyCoordinator = VocabularyCoordinator(
            navigationController: navigationController,
            episodeID: episodeID
        )
        return coordinate(to: vocabularyCoordinator)
    }

    private func showEpisodeDetailFromPlaying() {
        guard let viewController = episodeDetailViewController else { return }
        // FIXME: The detail view is incorrect with the audio
        navigationController.pushViewController(viewController, animated: true)
    }
}
