//
//  BaseViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    func showConfirmAlert(title: String?, message: String?,
                          confirmHandler: ((UIAlertAction) -> Void)?,
                          completionHandler: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: confirmHandler)
        alert.addAction(action)
        present(alert, animated: true, completion: completionHandler)
    }
}
