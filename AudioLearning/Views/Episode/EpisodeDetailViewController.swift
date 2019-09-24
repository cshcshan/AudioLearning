//
//  EpisodeDetailViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/3.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EpisodeDetailViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var htmlTextView: UITextView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerViewHeight: NSLayoutConstraint!
    private let refreshControl = UIRefreshControl()
    
    var viewModel: EpisodeDetailViewModel!
    var musicPlayerViewController: MusicPlayerViewController!
    private let maxPlayerViewHeight: CGFloat = 195.5
    private let minPlayerViewHeight: CGFloat = 76
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        // playerView
        addChild(musicPlayerViewController)
        musicPlayerViewController.view.frame = playerView.bounds
        playerView.addSubview(musicPlayerViewController.view)
        playerView.sendSubviewToBack(musicPlayerViewController.view)
        addPanToPlayerView()
        // refreshControl
        scrollView.isScrollEnabled = false
        scrollView.addSubview(refreshControl)
        // htmlTextView
        htmlTextView.isEditable = false
        htmlTextView.isScrollEnabled = true
    }
    
    private func setupBindings() {
        viewModel.refreshing
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (refreshing) in
                guard let `self` = self else { return }
                if refreshing {
                    self.refreshControl.beginRefreshing()
                } else {
                    self.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        navigationItem.title = viewModel.title
        
        viewModel.scriptHtml
            .observeOn(MainScheduler.instance)
            .map({ [weak self] (html) -> NSAttributedString in
                guard let `self` = self else { return NSAttributedString() }
                let fontName = self.htmlTextView.font!.fontName
                let fontSize = self.htmlTextView.font!.pointSize
                return "<style>body{font-family:'\(fontName)';font-size:\(fontSize)px;}</style>\(html)".convertHtml()
            })
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.refreshControl.endRefreshing()
            })
            .bind(to: htmlTextView.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.alert
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (alert) in
                guard let `self` = self else { return }
                self.showConfirmAlert(title: alert.title,
                                      message: alert.message,
                                      confirmHandler: nil,
                                      completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.initalLoad.onNext(())
    }
}

// MARK: - Pan Player View Up & Down

extension EpisodeDetailViewController {
    
    func addPanToPlayerView() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanPlayerView))
        playerView.addGestureRecognizer(pan)
    }
    
    @objc func handlePanPlayerView(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: playerView)
        let currentY = playerViewHeight.constant
        var finalY = currentY - translation.y
        
        switch recognizer.state {
        case .changed:
            if finalY > maxPlayerViewHeight { finalY = maxPlayerViewHeight }
            if finalY < minPlayerViewHeight { finalY = minPlayerViewHeight }
            playerViewHeight.constant = finalY
            playerView.superview?.layoutIfNeeded()
        case .ended:
            let distanceFromMax = abs(maxPlayerViewHeight - finalY)
            let distanceFromMin = abs(minPlayerViewHeight - finalY)
            if distanceFromMax > distanceFromMin {
                finalY = minPlayerViewHeight
            } else {
                finalY = maxPlayerViewHeight
            }
            UIView.animate(withDuration: 0.4) { [weak self] in
                guard let `self` = self else { return }
                self.playerViewHeight.constant = finalY
                self.playerView.superview?.layoutIfNeeded()
            }
        default: break
        }
    }
}
