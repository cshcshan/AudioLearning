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
        let viewModel = VocabularyListViewModel(realmService: realmService, episodeID: episodeID)

        // Vocabulary Detail
        let vocabularyDetailVC = newVocabularyDetailVC(vocabularyListViewModel: viewModel)

        viewModel.event.vocabularySelected.bind(to: vocabularyDetailVC.viewModel.load).disposed(by: bag)
        viewModel.event.addVocabulary.bind(to: vocabularyDetailVC.viewModel.add).disposed(by: bag)

        viewModel.event.flashCardsTapped
            .subscribe(with: self, onNext: { `self`, _ in self.showFlashCards() })
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

        viewModel.saved.bind(to: vocabularyListViewModel.event.fetchData).disposed(by: bag)

        viewModel.close.map { true }
            .bind(to: vocabularyListViewModel.state.isVocabularyDetailViewHidden)
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
