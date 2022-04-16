//
//  BaseViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import UIKit

class BaseViewController: UIViewController, StoryboardGettable {

    let bag = DisposeBag()

    var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITesting")
    }

    private var interactionController: UIPercentDrivenInteractiveTransition?

    private let tagOfThemeButton = 201
    private let tagOfPlayingButton = 202

    private var slidePushAnimator: SlidePushAnimator!
    private var slidePopAnimator: SlidePopAnimator!
    private var episodePushAnimator: EpisodePushAnimator!
    private var episodePopAnimator: EpisodePopAnimator!

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11, *) {
        } else {
            extendedLayoutIncludesOpaqueBars = true
        }
        setupNotification()
        setupUIID()
        setupUIColor()
        addScreenPanToView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if parent is UINavigationController {
            navigationController?.delegate = self
        }
    }

    override var prefersStatusBarHidden: Bool {
        false
    }

    func setupNotification() {
        NotificationCenter.default.rx
            .notification(.changeAppearance)
            .take(until: rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.setupUIColor()
            })
            .disposed(by: bag)
    }

    func setupUIID() {}

    func setupUIColor() {
        if let navigationBar = navigationController?.navigationBar {
//            navigationBar.backgroundColor = Appearance.mode == .dark ? UIColor.black : UIColor.white
            navigationBar.barTintColor = Appearance.mode == .dark ? UIColor.black : UIColor.white
            navigationBar.tintColor = Appearance.textColor
            navigationBar.barStyle = Appearance.mode == .dark ? .black : .default
            navigationBar.isTranslucent = false
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: Appearance.textColor,
                NSAttributedString.Key.font: UIFont(
                    name: "AvenirNext-DemiBold",
                    size: 20.0
                )!
            ]
        }
        if let themeButton = view.viewWithTag(tagOfThemeButton) {
            themeButton.backgroundColor = Appearance.textColor.withAlphaComponent(0.4)
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension BaseViewController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is EpisodeListViewController && toVC is EpisodeDetailViewController {
            if episodePushAnimator == nil {
                episodePushAnimator = EpisodePushAnimator()
            }
            return episodePushAnimator
        } else if fromVC is EpisodeDetailViewController && toVC is EpisodeListViewController {
            if episodePopAnimator == nil {
                episodePopAnimator = EpisodePopAnimator()
            }
            return episodePopAnimator
        }
        switch operation {
        case .push:
            if slidePushAnimator == nil {
                slidePushAnimator = SlidePushAnimator()
            }
            return slidePushAnimator
        case .pop:
            if slidePopAnimator == nil {
                slidePopAnimator = SlidePopAnimator()
            }
            return slidePopAnimator
        default: return nil
        }
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }
}

// MARK: - Theme Buttons & Playing Button

extension BaseViewController {

    func showThemeButton<T: BaseViewModel, U: UIView>(_ viewModel: T, to item: U) {
        guard view.viewWithTag(tagOfThemeButton) == nil else { return }
        let side: CGFloat = 50
        let themeButton = UIButton(type: .custom)
        themeButton.tag = tagOfThemeButton
        themeButton.setImage(UIImage(named: "theme"), for: .normal)
        themeButton.backgroundColor = Appearance.textColor.withAlphaComponent(0.4)
        themeButton.circle(side / 2)
        themeButton.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        themeButton.rx.tap
            .bind(to: viewModel.tapTheme)
            .disposed(by: bag)
        themeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(themeButton)
        setupConstraintsOnBottomRight(
            on: themeButton,
            to: item,
            constraints: (right: -20, bottom: -10),
            size: (width: side, height: side)
        )
    }

    func showPlayingButton<T: BaseViewModel, U: UIView>(_ viewModel: T, to item: U, isShow: Bool) {
        let execute = { [weak self] in
            guard let self = self else { return }
            let button = self.view.viewWithTag(self.tagOfPlayingButton)
            if isShow {
                guard button == nil else {
                    button!.addPulseAnimation()
                    button!.isHidden = false
                    return
                }
                let side: CGFloat = 50
                let playingButton = UIButton(type: .custom)
                playingButton.tag = self.tagOfPlayingButton
                playingButton.setImage(UIImage(named: "wave"), for: .normal)
                playingButton.backgroundColor = Appearance.textColor.withAlphaComponent(0.4)
                playingButton.circle(side / 2)
                playingButton.addPulseAnimation()
                playingButton.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                playingButton.rx.tap
                    .bind(to: viewModel.tapPlaying)
                    .disposed(by: self.bag)
                playingButton.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(playingButton)
                self.setupConstraintsOnBottomRight(
                    on: playingButton,
                    to: item,
                    constraints: (right: -20, bottom: -70),
                    size: (width: side, height: side)
                )
            } else {
                guard let playingButton = button else { return }
                playingButton.removePulseAnimation()
                playingButton.isHidden = true
            }
        }
        DispatchQueue.main.async {
            execute()
        }
    }

    func animatePlayingButton() {
        guard let playingButton = view.viewWithTag(tagOfPlayingButton), playingButton.isHidden == false else { return }
        playingButton.removePulseAnimation()
        playingButton.addPulseAnimation()
    }

    private func setupConstraintsOnBottomRight(
        on subview: UIView,
        to item: UIView,
        constraints: (right: CGFloat, bottom: CGFloat),
        size: (width: CGFloat, height: CGFloat)
    ) {
        let right = NSLayoutConstraint(
            item: subview,
            attribute: .right,
            relatedBy: .equal,
            toItem: item,
            attribute: .right,
            multiplier: 1,
            constant: constraints.right
        )
        let bottom = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: item,
            attribute: .bottom,
            multiplier: 1,
            constant: constraints.bottom
        )
        let width = NSLayoutConstraint(
            item: subview,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: size.width
        )
        let height = NSLayoutConstraint(
            item: subview,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: size.height
        )
        view.addConstraints([right, bottom, width, height])
    }

    func showConfirmAlert(
        title: String?,
        message: String?,
        confirmHandler: ((UIAlertAction) -> Void)?,
        completionHandler: (() -> Void)?
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: confirmHandler)
        alert.addAction(action)
        present(alert, animated: true, completion: completionHandler)
    }
}

// MARK: - Pan View

extension BaseViewController {

    private func addScreenPanToView() {
        if self == navigationController?.viewControllers.first {
        } else {
            let pan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenPanView))
            pan.edges = .left
            view.addGestureRecognizer(pan)
        }
    }

    @objc func handleScreenPanView(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        let offsetX = recognizer.translation(in: view).x
        let percent = abs(offsetX) / view.frame.width

        switch recognizer.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            if offsetX > 0 {
                navigationController?.popViewController(animated: true)
            }
        case .changed:
            interactionController?.update(percent)
        case .possible: break
        case .failed, .cancelled:
            interactionController?.cancel()
        case .ended:
            if percent > 0.5 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        default: break
        }
    }
}
