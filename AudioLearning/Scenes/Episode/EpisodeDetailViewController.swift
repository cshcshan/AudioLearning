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

    // MARK: - IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var htmlTextView: UITextView!
    @IBOutlet var maskView: UIView!
    @IBOutlet var vocabularyDetailContainerView: UIView!

    private let refreshControl = UIRefreshControl()
    private var item: UIMenuItem!

    private let darkBgTempImage = UIImage(named: "temp_pic-white")
    private let lightBgTempImage = UIImage(named: "temp_pic")

    // MARK: - Properties

    var viewModel: EpisodeDetailViewModel!
    var audioPlayerVC: AudioPlayerViewController!
    var vocabularyDetailView: UIView!

    private var beganPlayerViewHeight: CGFloat = .zero
    private let maxPlayerViewHeight: CGFloat = 176.5 + 32 + 16 + 34
    private let minPlayerViewHeight: CGFloat = 124

    private lazy var audioPlayerView: UIView! = audioPlayerVC.view

    private var playerViewHeight: CGFloat {
        view.bounds.height - audioPlayerView.frame.minY
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        enableMenuItem()

        viewModel.event.fetchData.accept(())
    }

    // MARK: - Setup

    override func setupUIID() {
        audioPlayerView.accessibilityIdentifier = "PlayerView"
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
        addChild(audioPlayerVC)
        view.addSubview(audioPlayerView)
        audioPlayerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.bottom).inset(maxPlayerViewHeight)
        }
        setupPlayerViewShadow()
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
        audioPlayerView.layer.masksToBounds = false
        audioPlayerView.layer.shadowColor = UIColor.black.cgColor
        audioPlayerView.layer.shadowOpacity = 0.4
        audioPlayerView.layer.shadowOffset = CGSize(width: -2, height: -5)
        audioPlayerView.layer.shadowRadius = 5
        audioPlayerView.layer.shadowPath = UIBezierPath(rect: audioPlayerView.bounds).cgPath
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

        playerViewHeight == minPlayerViewHeight
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
        audioPlayerVC.viewModel.changeSpeedSegmentedControlAlpha.onNext(1)
        audioPlayerVC.viewModel.changeSliderAlpha.onNext(1)

        audioPlayerView.snp.updateConstraints {
            $0.top.equalTo(view.snp.bottom).inset(maxPlayerViewHeight)
        }
        audioPlayerView.superview?.setNeedsLayout()
        audioPlayerView.superview?.layoutIfNeeded()

        audioPlayerView.snp.updateConstraints {
            $0.top.equalTo(view.snp.bottom).inset(minPlayerViewHeight)
        }
        audioPlayerView.superview?.setNeedsLayout()
        UIView.animate(withDuration: 0.8) {
            self.audioPlayerVC.viewModel.changeSpeedSegmentedControlAlpha.onNext(0)
            self.audioPlayerVC.viewModel.changeSliderAlpha.onNext(0)
            self.audioPlayerView.superview?.layoutIfNeeded()
        }
    }

    private func addPanToPlayerView() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanPlayerView))
        audioPlayerView.addGestureRecognizer(pan)
    }

    @objc func handlePanPlayerView(_ recognizer: UIPanGestureRecognizer) {
        guard let recognizerView = recognizer.view else { return }

        let offset = recognizer.translation(in: recognizerView)
        let velocity = recognizer.velocity(in: recognizerView)

        switch recognizer.state {
        case .began:
            beganPlayerViewHeight = recognizerView.bounds.height - audioPlayerView.frame.minY
        case .changed:
            var finalY = beganPlayerViewHeight - offset.y
            if finalY > maxPlayerViewHeight { finalY = maxPlayerViewHeight }
            if finalY < minPlayerViewHeight { finalY = minPlayerViewHeight }
            finalY == minPlayerViewHeight
                ? viewModel.event.shrinkAudioPlayer.accept(())
                : viewModel.event.enlargeAudioPlayer.accept(())

            audioPlayerView.snp.updateConstraints {
                $0.top.equalTo(self.view.snp.bottom).inset(finalY)
            }
            audioPlayerView.superview?.layoutIfNeeded()
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
                self.audioPlayerView.snp.updateConstraints {
                    $0.top.equalTo(self.view.snp.bottom).inset(finalY)
                }
                self.audioPlayerView.superview?.layoutIfNeeded()
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
