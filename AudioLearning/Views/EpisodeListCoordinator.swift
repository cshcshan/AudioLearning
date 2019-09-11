//
//  EpisodeListCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class EpisodeListCoordinator: Coordinator {
    
    private let window: UIWindow
    private var navigationController: UINavigationController!
    
    required init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        self.showEpisodeList()
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
    }
    
    private func showEpisodeList() {
        // ViewModel
        let parseSixMinutesHelper = ParseSixMinutesHelper()
        let apiService = APIService(parseSMHelper: parseSixMinutesHelper)
        let viewModel = EpisodeListViewModel(apiService: apiService)
        
        // ViewController
        let episodeListViewController = EpisodeListViewController.initialize(from: "Main", storyboardID: "EpisodeList")
        episodeListViewController.viewModel = viewModel
        navigationController = UINavigationController(rootViewController: episodeListViewController)
    }
}
