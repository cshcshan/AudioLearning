//
//  BaseViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController, StoryboardGettable {
    
    let disposeBag = DisposeBag()

    var isUITesting: Bool {
        return ProcessInfo.processInfo.arguments.contains("-UITesting")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupUIID()
        setupUIColor()
    }
    
    private func setupNotification() {
        NotificationCenter.default.rx
            .notification(.changeAppearance)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.setupUIColor()
            })
            .disposed(by: disposeBag)
    }
    
    func setupUIID() {}
    
    func setupUIColor() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.backgroundColor = Appearance.mode == .dark ? UIColor.black : UIColor.white
            navigationBar.barTintColor = Appearance.mode == .dark ? UIColor.black : UIColor.white
            navigationBar.tintColor = Appearance.textColor
            navigationBar.isTranslucent = false
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Appearance.textColor,
                                                 NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 20.0)!]
        }
    }

    func addThemeButton<T: BaseViewModel, U: UIView>(_ viewModel: T, to item: U) {
        let themeButton = UIButton(type: .custom)
        themeButton.setImage(UIImage(named: "theme"), for: UIControl.State())
        themeButton.rx.tap
            .bind(to: viewModel.tapTheme)
            .disposed(by: disposeBag)
        themeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(themeButton)
        let right = NSLayoutConstraint(item: themeButton, attribute: .right, relatedBy: .equal, toItem: item, attribute: .right, multiplier: 1, constant: -20)
        let bottom = NSLayoutConstraint(item: themeButton, attribute: .bottom, relatedBy: .equal, toItem: item, attribute: .bottom, multiplier: 1, constant: -20)
        let width = NSLayoutConstraint(item: themeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35)
        let height = NSLayoutConstraint(item: themeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35)
        view.addConstraints([right, bottom, width, height])
    }
    
    func showConfirmAlert(title: String?, message: String?,
                          confirmHandler: ((UIAlertAction) -> Void)?,
                          completionHandler: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: confirmHandler)
        alert.addAction(action)
        present(alert, animated: true, completion: completionHandler)
    }
}
