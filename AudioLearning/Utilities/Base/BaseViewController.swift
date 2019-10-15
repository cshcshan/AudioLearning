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
    
    private let tagOfThemeButton = 201
    private let tagOfPlayingButton = 202
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupUIID()
        setupUIColor()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func setupNotification() {
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
//            navigationBar.backgroundColor = Appearance.mode == .dark ? UIColor.black : UIColor.white
            navigationBar.barTintColor = Appearance.mode == .dark ? UIColor.black : UIColor.white
            navigationBar.tintColor = Appearance.textColor
            navigationBar.barStyle = Appearance.mode == .dark ? .black : .default
            navigationBar.isTranslucent = false
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Appearance.textColor,
                                                 NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 20.0)!]
        }
        if let themeButton = view.viewWithTag(tagOfThemeButton) {
            themeButton.backgroundColor = Appearance.textColor.withAlphaComponent(0.4)
        }
    }

    func showThemeButton<T: BaseViewModel, U: UIView>(_ viewModel: T, to item: U) {
        guard view.viewWithTag(tagOfThemeButton) == nil else { return }
        let side: CGFloat = 50
        let themeButton = UIButton(type: .custom)
        themeButton.tag = tagOfThemeButton
        themeButton.setImage(UIImage(named: "theme"), for: UIControl.State())
        themeButton.backgroundColor = Appearance.textColor.withAlphaComponent(0.4)
        themeButton.circle(side / 2)
        themeButton.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        themeButton.rx.tap
            .bind(to: viewModel.tapTheme)
            .disposed(by: disposeBag)
        themeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(themeButton)
        setupConstraintsOnBottomRight(on: themeButton, to: item,
                                      constraints: (right: -20, bottom: -10),
                                      size: (width: side, height: side))
    }
    
    func showPlayingButton<T: BaseViewModel, U: UIView>(_ viewModel: T, to item: U, isShow: Bool) {
        let button = view.viewWithTag(tagOfPlayingButton)
        if isShow {
            guard button == nil else {
                button!.addPulseAnimation()
                button!.isHidden = false
                return
            }
            let side: CGFloat = 50
            let playingButton = UIButton(type: .custom)
            playingButton.tag = tagOfPlayingButton
            playingButton.setImage(UIImage(named: "wave"), for: UIControl.State())
            playingButton.backgroundColor = Appearance.textColor.withAlphaComponent(0.4)
            playingButton.circle(side / 2)
            playingButton.addPulseAnimation()
            playingButton.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            playingButton.rx.tap
                .bind(to: viewModel.tapPlaying)
                .disposed(by: disposeBag)
            playingButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(playingButton)
            setupConstraintsOnBottomRight(on: playingButton, to: item,
                                          constraints: (right: -20, bottom: -70),
                                          size: (width: side, height: side))
        } else {
            guard let playingButton = button else { return }
            playingButton.removePulseAnimation()
            playingButton.isHidden = true
        }
    }
    
    func animatePlayingButton() {
        guard let playingButton = view.viewWithTag(tagOfPlayingButton), playingButton.isHidden == false else { return }
        playingButton.removePulseAnimation()
        playingButton.addPulseAnimation()
    }
    
    private func setupConstraintsOnBottomRight(on subview: UIView, to item: UIView,
                                               constraints: (right: CGFloat, bottom: CGFloat),
                                               size: (width: CGFloat, height: CGFloat)) {
        let right = NSLayoutConstraint(item: subview, attribute: .right, relatedBy: .equal, toItem: item,
                                       attribute: .right, multiplier: 1, constant: constraints.right)
        let bottom = NSLayoutConstraint(item: subview, attribute: .bottom, relatedBy: .equal, toItem: item,
                                        attribute: .bottom, multiplier: 1, constant: constraints.bottom)
        let width = NSLayoutConstraint(item: subview, attribute: .width, relatedBy: .equal, toItem: nil,
                                       attribute: .notAnAttribute, multiplier: 1, constant: size.width)
        let height = NSLayoutConstraint(item: subview, attribute: .height, relatedBy: .equal, toItem: nil,
                                        attribute: .notAnAttribute, multiplier: 1, constant: size.height)
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
