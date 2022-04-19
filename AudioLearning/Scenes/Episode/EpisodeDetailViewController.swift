//
//  EpisodeDetailViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/3.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class EpisodeDetailViewController: BaseViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var htmlTextView: UITextView!
    @IBOutlet var playerView: UIView!
    @IBOutlet var playerViewHeight: NSLayoutConstraint!
    @IBOutlet var maskView: UIView!
    @IBOutlet var vocabularyDetailContainerView: UIView!
    private let refreshControl = UIRefreshControl()
    private var item: UIMenuItem!

    private let darkBgTempImage = UIImage(named: "temp_pic-white")
    private let lightBgTempImage = UIImage(named: "temp_pic")

    var viewModel: EpisodeDetailViewModel!
    var musicPlayerView: UIView!
    var vocabularyDetailView: UIView!
    private var beganPlayerViewHeight: CGFloat = .zero
    private let maxPlayerViewHeight: CGFloat = 176.5 + 32 + 16
    private let minPlayerViewHeight: CGFloat = 90

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        enableMenuItem()

        viewModel.event.fetchData.accept(())
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
        scrollView.contentInsetAdjustmentBehavior = .never
        setupNavigationBar()
        addTapToMaskView()
        // playerView
        setupPlayerViewShadow()
        musicPlayerView.frame = playerView.bounds
        playerView.clipsToBounds = true
        playerView.addSubview(musicPlayerView)
        playerView.sendSubviewToBack(musicPlayerView)
        animatePlayerViewHeight()
        addPanToPlayerView()
        // refreshControl
        if !isUITesting {
            refreshControl.tintColor = Appearance.textColor
            scrollView.isScrollEnabled = true
            scrollView.addSubview(refreshControl)
            scrollView
                .contentOffset = CGPoint(
                    x: 0,
                    y: -refreshControl.frame.height
                ) // for changing refreshControl's tintColor
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
        vocabularyItem.rx.tap.bind(to: viewModel.event.vocabularyTapped).disposed(by: bag)
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
            viewModel.state.isRefreshing.drive(refreshControl.rx.isRefreshing).disposed(by: bag)
        }

        navigationItem.title = viewModel.title

        viewModel.state.image.asDriver()
            .drive(with: self, onNext: { `self`, image in
                self.photoImageView.image = image == nil ? self.getNormalImage() : image
            })
            .disposed(by: bag)

        viewModel.state.scriptHtmlString
            .map { [weak self] htmlString -> NSAttributedString in
                guard let self = self,
                      let fontName = self.htmlTextView.font?.fontName,
                      let fontSize = self.htmlTextView.font?.pointSize
                else { return NSAttributedString() }

                return htmlString.convertHtml(
                    backgroundColor: Appearance.backgroundColor,
                    fontColor: Appearance.textColor,
                    fontName: fontName,
                    fontSize: fontSize
                )
            }
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .drive(htmlTextView.rx.attributedText)
            .disposed(by: bag)

        viewModel.event.showAlert.asSignal()
            .emit(with: self, onNext: { `self`, alert in
                self.showConfirmAlert(
                    title: alert.title,
                    message: alert.message,
                    confirmHandler: nil,
                    completionHandler: nil
                )
            })
            .disposed(by: bag)

        viewModel.state.isVocabularyDetailViewHidden.asDriver()
            .drive(maskView.rx.isHidden)
            .disposed(by: bag)

        viewModel.state.isVocabularyDetailViewHidden
            .filter { $0 }
            .do(onNext: { [weak self] _ in self?.enableMenuItem() })
            .map { _ in TimeInterval(0.4) }
            .bind(to: maskView.rx.fadeOut)
            .disposed(by: bag)

        viewModel.state.isVocabularyDetailViewHidden
            .filter { $0 == false }
            .do(onNext: { [weak self] _ in self?.disableMenuItem() })
            .map { _ in TimeInterval(0.4) }
            .bind(to: maskView.rx.fadeIn)
            .disposed(by: bag)

        playerViewHeight.constant == minPlayerViewHeight
            ? viewModel.event.shrinkAudioPlayer.accept(())
            : viewModel.event.enlargeAudioPlayer.accept(())
    }

    private func getNormalImage() -> UIImage? {
        Appearance.mode == .dark ? darkBgTempImage : lightBgTempImage
    }
}

// MARK: - Tap Mask View

extension EpisodeDetailViewController {

    private func addTapToMaskView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapView))
        maskView.addGestureRecognizer(tap)
    }

    @objc func handleTapView(_ recognizer: UITapGestureRecognizer) {
        viewModel.state.isVocabularyDetailViewHidden.accept(true)
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
            guard let self = self else { return }
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
            finalY == minPlayerViewHeight
                ? viewModel.event.shrinkAudioPlayer.accept(())
                : viewModel.event.enlargeAudioPlayer.accept(())
            playerViewHeight.constant = finalY
            playerView.superview?.layoutIfNeeded()
        case .ended:
            var finalY = beganPlayerViewHeight
            if offset.y > 50 || velocity.y > 500 {
                finalY = minPlayerViewHeight
            } else if offset.y < -50 || velocity.y < -500 {
                finalY = maxPlayerViewHeight
            }
            UIView.animate(withDuration: 0.4) {
                finalY == self.minPlayerViewHeight
                    ? self.viewModel.event.shrinkAudioPlayer.accept(())
                    : self.viewModel.event.enlargeAudioPlayer.accept(())
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
        guard let textRange = htmlTextView.selectedTextRange,
              let text = htmlTextView.text(in: textRange)
        else { return }
        viewModel.event.addVocabularyTapped.accept(text)
    }
}
