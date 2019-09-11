//
//  AppCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

protocol Coordinator {
    init(window: UIWindow)
    func start()
}

class AppCoordinator: Coordinator {
    
    private let window: UIWindow
    
    required init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let episodeListCoordinator = EpisodeListCoordinator(window: window)
        episodeListCoordinator.start()
    }
}
