//
//  StoryboardGettable.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

enum StoryboardName: String {
    case episode = "Episode"
    case musicPlayer = "MusicPlayer"
    case vocabulary = "Vocabulary"
    case flashCards = "FlashCards"
}

enum StoryboardID: String {
    case episodeList = "EpisodeList"
    case episodeDetail = "EpisodeDetail"
    case musicPlayerViewController = "MusicPlayerViewController"
    case vocabularyListViewController = "VocabularyListViewController"
    case vocabularyDetailViewController = "VocabularyDetailViewController"
    case flashCardsViewController = "FlashCardsViewController"
}

protocol StoryboardGettable {}

extension StoryboardGettable where Self: UIViewController {
    
    static func initialize(from storyboardName: StoryboardName, storyboardID: StoryboardID? = nil) -> Self {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: Bundle.main)
        var viewController: Self?
        if let storyboardID = storyboardID {
            if let vc = storyboard.instantiateViewController(withIdentifier: storyboardID.rawValue) as? Self {
                viewController = vc
            }
        } else {
            if let vc = storyboard.instantiateInitialViewController() as? Self {
                viewController = vc
            }
        }
        return viewController ?? Self()
    }
}
