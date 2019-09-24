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
        
        viewModel.showVocabularyDetail
            .subscribe(onNext: { [weak self] (model) in
                guard let `self` = self else { return }
                self.showVocabularyDetail(vocabularyListViewModel: viewModel, model: model)
            })
            .disposed(by: disposeBag)
        
        viewModel.showAddVocabularyDetail
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.showAddVocabularyDetail(vocabularyListViewModel: viewModel)
            })
            .disposed(by: disposeBag)
        
        // ViewController
        let viewController = VocabularyListViewController.initialize(from: "Vocabulary", storyboardID: "VocabularyListViewController")
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showVocabularyDetail(vocabularyListViewModel: VocabularyListViewModel, handler: @escaping ((VocabularyDetailViewModel) -> Void)) {
        // ViewModel
        let realmService = RealmService<VocabularyRealmModel>()
        let viewModel = VocabularyDetailViewModel(realmService: realmService)
        
        viewModel.saved
            .subscribe(onNext: { (_) in
                vocabularyListViewModel.reload.onNext(())
            })
            .disposed(by: disposeBag)
        
        // ViewController
        let viewController = VocabularyDetailViewController.initialize(from: "Vocabulary", storyboardID: "VocabularyDetailViewController")
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
        
        handler(viewModel)
    }
    
    private func showVocabularyDetail(vocabularyListViewModel: VocabularyListViewModel, model: VocabularyRealmModel) {
        showVocabularyDetail(vocabularyListViewModel: vocabularyListViewModel, handler: { $0.load.onNext(model) })
    }
    
    private func showAddVocabularyDetail(vocabularyListViewModel: VocabularyListViewModel) {
        showVocabularyDetail(vocabularyListViewModel: vocabularyListViewModel, handler: { $0.add.onNext(()) })
    }
}
