//
//  VocabularyCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift

class VocabularyCoordinator: BaseCoordinator<Void> {
    
    private var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        self.showVocabularyList()
        return .never()
    }
    
    private func showVocabularyList() {
        // ViewModel
        let realmService = RealmService<VocabularyRealmModel>()
        let viewModel = VocabularyListViewModel(realmService: realmService)
        
        // ViewController
        let viewController = VocabularyListViewController.initialize(from: "Vocabulary", storyboardID: "VocabularyListViewController")
        viewController.viewModel = viewModel
        viewController.vocabularyDetailViewController = showVocabularyDetail(vocabularyListViewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showVocabularyDetail(vocabularyListViewModel: VocabularyListViewModel) -> VocabularyDetailViewController {
        // ViewModel
        let realmService = RealmService<VocabularyRealmModel>()
        let viewModel = VocabularyDetailViewModel(realmService: realmService)
        
        viewModel.saved
            .subscribe(onNext: { (_) in
                vocabularyListViewModel.reload.onNext(())
            })
            .disposed(by: disposeBag)
        
        viewModel.close.map({ true })
            .bind(to: vocabularyListViewModel.hideVocabularyDetailView)
            .disposed(by: disposeBag)
        
        // ViewController
        let viewController = VocabularyDetailViewController.initialize(from: "Vocabulary", storyboardID: "VocabularyDetailViewController")
        viewController.viewModel = viewModel
        
        return viewController
    }
}
