//
//  VocabularyCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class VocabularyCoordinator: Coordinator<Void> {

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

        viewModel.event.vocabularySelected
            .bind(to: vocabularyDetailVC.viewModel.state.vocabulary)
            .disposed(by: bag)

        viewModel.event.addVocabulary.bind(to: vocabularyDetailVC.viewModel.event.reset).disposed(by: bag)

        viewModel.event.flashCardsTapped
            .flatMapLatest { [weak self] _ in self?.showFlashCards() ?? .empty() }
            .subscribe()
            .disposed(by: bag)

        // ViewController
        let viewController = VocabularyListViewController.initialize(
            from: .vocabulary,
            storyboardID: .vocabularyListViewController
        )
        viewController.viewModel = viewModel
        viewController.vocabularyDetailView = vocabularyDetailVC.view
        viewController.addChild(vocabularyDetailVC)

        vocabularyDetailVC.viewModel.event.showAlert.asSignal()
            .emit(onNext: { alert in
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

        viewModel.event.saveSuccessfully.bind(to: vocabularyListViewModel.event.fetchData).disposed(by: bag)

        Signal
            .merge(viewModel.event.saveSuccessfully.asSignal(), viewModel.event.cancel.asSignal())
            .map { _ in true }
            .emit(to: vocabularyListViewModel.state.isVocabularyDetailViewHidden)
            .disposed(by: bag)

        // ViewController
        let viewController = VocabularyDetailViewController.initialize(
            from: .vocabulary,
            storyboardID: .vocabularyDetailViewController
        )
        viewController.viewModel = viewModel

        return viewController
    }

    private func showFlashCards() -> Observable<Void> {
        let flashCardsCoordinator = FlashCardsCoordinator(navigationController: navigationController)
        return coordinate(to: flashCardsCoordinator)
    }
}
