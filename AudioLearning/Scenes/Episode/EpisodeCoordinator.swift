//
//  EpisodeCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class EpisodeCoordinator: Coordinator<Void> {

    private let window: UIWindow
    private var navigationController: UINavigationController!
    private var episodeDetailViewController: EpisodeDetailViewController?

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
        viewModel.showEpisodeDetailFromPlaying.asSignal(onErrorSignalWith: .empty())
            .emit(with: self, onNext: { `self`, _ in self.showEpisodeDetailFromPlaying() })
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

        // Audio and Vocabulary Detail
        let audioPlayerVC = makeAudioPlayerVC()
        let vocabularyDetailVC = makeVocabularyDetailVC(
            isVocabularyDetailViewHidden: viewModel.state.isVocabularyDetailViewHidden
        )

        viewModel.state.audioURLString
            .compactMap(URL.init)
            .drive(audioPlayerVC.viewModel.settingNewAudio)
            .disposed(by: bag)

        viewModel.event.shrinkAudioPlayer.asSignal()
            .map { _ in 0 }
            .emit(
                to: audioPlayerVC.viewModel.changeSpeedSegmentedControlAlpha,
                audioPlayerVC.viewModel.changeSliderAlpha
            )
            .disposed(by: bag)

        viewModel.event.enlargeAudioPlayer.asSignal()
            .map { _ in 1 }
            .emit(
                to: audioPlayerVC.viewModel.changeSpeedSegmentedControlAlpha,
                audioPlayerVC.viewModel.changeSliderAlpha
            )
            .disposed(by: bag)

        viewModel.event.addVocabularyTapped
            .map { word in (episode.id, word) }
            .bind(to: vocabularyDetailVC.viewModel.addWithWord)
            .disposed(by: bag)

        // ViewController
        let viewController = EpisodeDetailViewController.initialize(from: .episode, storyboardID: .episodeDetail)
        viewController.viewModel = viewModel
        viewController.audioPlayerVC = audioPlayerVC
        viewController.vocabularyDetailView = vocabularyDetailVC.view
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

    private func makeAudioPlayerVC() -> AudioPlayerViewController {
        let player = HCAudioPlayer()
        let audioPlayerViewModel = AudioPlayerViewModel(player: player)
        let viewController = AudioPlayerViewController.initialize(
            from: .audioPlayer,
            storyboardID: .audioPlayerViewController
        )
        viewController.viewModel = audioPlayerViewModel
        return viewController
    }

    private func makeVocabularyDetailVC(
        isVocabularyDetailViewHidden: BehaviorRelay<Bool>
    ) -> VocabularyDetailViewController {
        // ViewModel
        let realmService = RealmService<VocabularyRealm>()
        let viewModel = VocabularyDetailViewModel(realmService: realmService)

        viewModel.close.map { true }.bind(to: isVocabularyDetailViewHidden).disposed(by: bag)

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
