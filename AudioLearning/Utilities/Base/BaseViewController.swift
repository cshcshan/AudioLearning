//
//  BaseViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, StoryboardGettable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIColor()
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.backgroundColor = appearanceMode == .dark ? UIColor.black : UIColor.white
            navigationBar.barTintColor = appearanceMode == .dark ? UIColor.black : UIColor.white
            navigationBar.tintColor = Appearance.textColor
            navigationBar.isTranslucent = false
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Appearance.textColor,
                                                 NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 20.0)!]
        }
    }
    
    func setupUIColor() {}
    
    func showConfirmAlert(title: String?, message: String?,
                          confirmHandler: ((UIAlertAction) -> Void)?,
                          completionHandler: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: confirmHandler)
        alert.addAction(action)
        present(alert, animated: true, completion: completionHandler)
    }
}
