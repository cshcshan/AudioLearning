//
//  StoryboardGettable.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

protocol StoryboardGettable {
    
}

extension StoryboardGettable where Self: UIViewController {
    
    // swiftlint:disable force_cast
    static func initialize(from storyboardName: String, storyboardID: String? = nil) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        guard let id = storyboardID else {
            return storyboard.instantiateInitialViewController() as! Self
        }
        return storyboard.instantiateViewController(withIdentifier: id) as! Self
    }
    // swiftlint:enable force_cast
}
