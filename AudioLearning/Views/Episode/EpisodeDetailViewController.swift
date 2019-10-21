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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var htmlTextView: UITextView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var vocabularyDetailContainerView: UIView!
    private let refreshControl = UIRefreshControl()
    private var item: UIMenuItem!
    
    private let darkBgTempImage = UIImage(named: "temp_pic-white")
    private let lightBgTempImage = UIImage(named: "temp_pic")
    
    var viewModel: EpisodeDetailViewModel!
    var musicPlayerView: UIView!
    var vocabularyDetailView: UIView!
    private var beganPlayerViewHeight: CGFloat = .zero
    private let maxPlayerViewHeight: CGFloat = 195.5
    private let minPlayerViewHeight: CGFloat = 76

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        enableMenuItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
    }
    
    override func setupUIID() {
        playerView.accessibilityIdentifier = "PlayerView"
    }
    
    override func setupUIColor() {
        super.setupUIColor()
        view.backgroundColor = Appearance.backgroundColor
        scrollView.backgroundColor = Appearance.backgroundColor
        contentView.backgroundColor = Appearance.backgroundColor
        photoImageView.backgroundColor = Appearance.backgroundColor
        htmlTextView.backgroundColor = Appearance.backgroundColor
        maskView.backgroundColor = Appearance.textColor.withAlphaComponent(0.4)
        refreshControl.tintColor = Appearance.textColor
        if photoImageView.image == darkBgTempImage || photoImageView.image == lightBgTempImage {
            photoImageView.image = getNormalImage()
        }
    }
    
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()
        // playerView
        setupPlayerViewShadow()
        musicPlayerView.frame = playerView.bounds
        playerView.addSubview(musicPlayerView)
        playerView.sendSubviewToBack(musicPlayerView)
        animatePlayerViewHeight()
        addPanToPlayerView()
        // refreshControl
        if !isUITesting {
            refreshControl.tintColor = Appearance.textColor
            scrollView.isScrollEnabled = true
            scrollView.addSubview(refreshControl)
            scrollView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.height) // for changing refreshControl's tintColor
        }
        // htmlTextView
        htmlTextView.isEditable = false
        htmlTextView.isScrollEnabled = false
        // vocabularyDetailView
        vocabularyDetailContainerView.backgroundColor = .clear
        vocabularyDetailContainerView.frame = vocabularyDetailView.bounds
        vocabularyDetailContainerView.addSubview(vocabularyDetailView)
        vocabularyDetailView.layer.cornerRadius = 10
    }
    
    private func setupNavigationBar() {
        let image = UIImage(named: "dictionary-filled")
        let vocabularyItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        vocabularyItem.rx.tap
            .bind(to: viewModel.tapVocabulary)
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItems = [vocabularyItem]
    }
    
    private func setupPlayerViewShadow() {
        playerView.layer.masksToBounds = false
        playerView.layer.shadowColor = UIColor.black.cgColor
        playerView.layer.shadowOpacity = 0.4
        playerView.layer.shadowOffset = CGSize(width: -2, height: -5)
        playerView.layer.shadowRadius = 5
        playerView.layer.shadowPath = UIBezierPath(rect: playerView.bounds).cgPath
    }
    
    private func setupBindings() {
        if !isUITesting {
            viewModel.refreshing
                .bind(to: refreshControl.rx.isRefreshing)
                .disposed(by: disposeBag)
        }
        
        navigationItem.title = viewModel.title
        
        viewModel.image
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (image) in
                guard let `self` = self else { return }
                if image == nil {
                    self.photoImageView.image = self.getNormalImage()
                } else {
                    self.photoImageView.image = image
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.scriptHtml
            .observeOn(MainScheduler.instance)
            .map({ [weak self] (html) -> NSAttributedString in
                guard let `self` = self else { return NSAttributedString() }
                let fontName = self.htmlTextView.font!.fontName
                let fontSize = self.htmlTextView.font!.pointSize
                return html.convertHtml(backgroundColor: Appearance.backgroundColor,
                                        fontColor: Appearance.textColor,
                                        fontName: fontName,
                                        fontSize: fontSize)
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
        
        viewModel.hideVocabularyDetailView
            .bind(to: maskView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.hideVocabularyDetailView
            .filter({ $0 == true })
            .flatMap({ [weak self] (_) -> Observable<TimeInterval> in
                guard let `self` = self else { return .just(TimeInterval(0)) }
                self.enableMenuItem()
                return .just(TimeInterval(0.4))
            })
            .bind(to: maskView.rx.fadeOut)
            .disposed(by: disposeBag)
        
        viewModel.hideVocabularyDetailView
            .filter({ $0 == false })
            .flatMap({ [weak self] (_) -> Observable<TimeInterval> in
                guard let `self` = self else { return .just(TimeInterval(0)) }
                self.disableMenuItem()
                return .just(TimeInterval(0.4))
            })
            .bind(to: maskView.rx.fadeIn)
            .disposed(by: disposeBag)
        
        viewModel.load.onNext(())
        
        playerViewHeight.constant == minPlayerViewHeight ?
            viewModel.shrinkMusicPlayer.onNext(()) : viewModel.enlargeMusicPlayer.onNext(())
    }
    
    private func getNormalImage() -> UIImage? {
        return Appearance.mode == .dark ? darkBgTempImage : lightBgTempImage
    }
}

// MARK: - Pan Player View Up & Down

extension EpisodeDetailViewController {
    
    func animatePlayerViewHeight() {
        playerViewHeight.constant = maxPlayerViewHeight
        playerView.superview?.setNeedsLayout()
        playerView.superview?.layoutIfNeeded()
        playerViewHeight.constant = minPlayerViewHeight
        playerView.superview?.setNeedsLayout()
        UIView.animate(withDuration: 0.8, animations: { [weak self] in
            guard let `self` = self else { return }
            self.playerView.superview?.layoutIfNeeded()
        })
    }
    
    func addPanToPlayerView() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanPlayerView))
        playerView.addGestureRecognizer(pan)
    }
    
    @objc func handlePanPlayerView(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        let offset = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        
        switch recognizer.state {
        case .began:
            beganPlayerViewHeight = playerViewHeight.constant
        case .changed:
            var finalY = beganPlayerViewHeight - offset.y
            if finalY > maxPlayerViewHeight { finalY = maxPlayerViewHeight }
            if finalY < minPlayerViewHeight { finalY = minPlayerViewHeight }
            finalY == minPlayerViewHeight ?
                viewModel.shrinkMusicPlayer.onNext(()) : viewModel.enlargeMusicPlayer.onNext(())
            playerViewHeight.constant = finalY
            playerView.superview?.layoutIfNeeded()
        case .ended:
            var finalY = beganPlayerViewHeight
            if offset.y > 50 || velocity.y > 500 {
                finalY = minPlayerViewHeight
            } else if offset.y < -50 || velocity.y < -500 {
                finalY = maxPlayerViewHeight
            }
            UIView.animate(withDuration: 0.4) { [weak self] in
                guard let `self` = self else { return }
                finalY == self.minPlayerViewHeight ?
                    self.viewModel.shrinkMusicPlayer.onNext(()) : self.viewModel.enlargeMusicPlayer.onNext(())
                self.playerViewHeight.constant = finalY
                self.playerView.superview?.layoutIfNeeded()
            }
        default: break
        }
    }
}

// MARK: - Add to Vocabulary

extension EpisodeDetailViewController {
    
    private func enableMenuItem() {
        if item == nil {
            item = UIMenuItem(title: "Add to Vocabulary", action: #selector(addVocabulary))
        }
        UIMenuController.shared.menuItems = [item]
    }
    
    private func disableMenuItem() {
        UIMenuController.shared.menuItems = []
    }
    
    @objc func addVocabulary() {
        guard let textRange = htmlTextView.selectedTextRange else { return }
        guard let text = htmlTextView.text(in: textRange) else { return }
        viewModel.addVocabulary.onNext(text)
    }
}
