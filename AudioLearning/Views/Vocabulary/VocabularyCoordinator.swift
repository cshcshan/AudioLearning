//
//  VocabularyCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import UIKit

final class VocabularyCoordinator: BaseCoordinator<Void> {

    private var navigationController: UINavigationController!
    private var episodeID: String?

    init(navigationController: UINavigationController, episodeID: String?) {
        self.navigationController = navigationController
        self.episodeID = episodeID
    }

    override func start() -> Observable<Void> {
        showVocabularyList()
        return .empty()
    }

    private func showVocabularyList() {
        // ViewModel
        let realmService = RealmService<VocabularyRealm>()
        let viewModel = VocabularyListViewModel(realmService: realmService)
        viewModel.setEpisode.onNext(episodeID)

        // Vocabulary Detail
        let vocabularyDetailVC = newVocabularyDetailVC(vocabularyListViewModel: viewModel)

        viewModel.showVocabularyDetail
            .subscribe(onNext: { vocabularyRealm in
                vocabularyDetailVC.viewModel.load.onNext(vocabularyRealm)
            })
            .disposed(by: bag)

        viewModel.showAddVocabularyDetail
            .subscribe(onNext: { _ in
                vocabularyDetailVC.viewModel.add.onNext(())
            })
            .disposed(by: bag)

        viewModel.showFlashCards
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showFlashCards()
            })
            .disposed(by: bag)

        // ViewController
        let viewController = VocabularyListViewController.initialize(
            from: .vocabulary,
            storyboardID: .vocabularyListViewController
        )
        viewController.viewModel = viewModel
        viewController.vocabularyDetailView = vocabularyDetailVC.view
        viewController.addChild(vocabularyDetailVC)

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

        navigationController.pushViewController(viewController, animated: true)
    }

    private func newVocabularyDetailVC(vocabularyListViewModel: VocabularyListViewModel)
        -> VocabularyDetailViewController {
        // ViewModel
        let realmService = RealmService<VocabularyRealm>()
        let viewModel = VocabularyDetailViewModel(realmService: realmService)

        viewModel.saved
            .subscribe(onNext: { _ in
                vocabularyListViewModel.reload.onNext(())
            })
            .disposed(by: bag)

        viewModel.close.map { true }
            .bind(to: vocabularyListViewModel.hideVocabularyDetailView)
            .disposed(by: bag)

        // ViewController
        let viewController = VocabularyDetailViewController.initialize(
            from: .vocabulary,
            storyboardID: .vocabularyDetailViewController
        )
        viewController.viewModel = viewModel

        return viewController
    }

    private func showFlashCards() {
        let flashCardsCoordinator = FlashCardsCoordinator(navigationController: navigationController)
        _ = coordinate(to: flashCardsCoordinator)
    }
}
