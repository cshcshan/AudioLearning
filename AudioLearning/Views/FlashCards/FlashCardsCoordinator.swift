//
//  FlashCardsCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FlashCardsCoordinator: BaseCoordinator<Void> {
    
    private var navigationController: UINavigationController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        self.showFlashCardList()
        return .empty()
    }
    
    private func showFlashCardList() {
        // ViewModel
        let realmService = RealmService<VocabularyRealmModel>()
        let viewModel = FlashCardsViewModel(realmService: realmService)
        
        // Vocabulary
        let viewController = FlashCardsViewController.initialize(from: .flashCards,
                                                                 storyboardID: .flashCardsViewController)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
    }
}
