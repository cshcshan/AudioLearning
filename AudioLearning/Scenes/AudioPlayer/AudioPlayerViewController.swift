//
//  AudioPlayerViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/12.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import UIKit

final class AudioPlayerViewController: UIViewController, StoryboardGettable {

    @IBOutlet var playButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var rewindButton: UIButton!
    @IBOutlet var speedSegmentedControl: UISegmentedControl!
    @IBOutlet var slider: BufferingSlider!
    @IBOutlet var progressTimerLabel: UILabel!
    @IBOutlet var totalLengthLabel: UILabel!

    var viewModel: AudioPlayerViewModel!
    private let bag = DisposeBag()

    private let playImage = UIImage(named: "play-white")
    private let pauseImage = UIImage(named: "pause-white")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupUIColor()
        setupUI()
        setupUI(isReady: false)
        setupBindings()
    }

    private func setupNotification() {
        NotificationCenter.default.rx.notification(.changeAppearance)
            .take(until: rx.deallocated)
            .subscribe(with: self, onNext: { `self`, _ in
                self.setupUIColor()
            })
            .disposed(by: bag)
    }

    private func setupUIColor() {
        let backgroundColor = Appearance.textColor
        let foreColor = Appearance.backgroundColor
        view.backgroundColor = backgroundColor
        let forwardImage = Appearance.mode == .dark
            ? UIImage(named: "forward-10")
            : UIImage(named: "forward-10-white")
        let rewindImage = Appearance.mode == .dark
            ? UIImage(named: "rewind-10")
            : UIImage(named: "rewind-10-white")
        forwardButton.setImage(forwardImage, for: .normal)
        rewindButton.setImage(rewindImage, for: .normal)
        speedSegmentedControl.tintColor = foreColor
        progressTimerLabel.textColor = foreColor
        totalLengthLabel.textColor = foreColor
    }

    private func setupUI() {
        setupBlurEffect()
    }

    private func setupBlurEffect() {
        // Blur Effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
        let views = ["subview": blurView]
        let horizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[subview]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        let vertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[subview]-0-|",
            options: [],
            metrics: nil,
            views: views
        )
        view.addConstraints(horizontal + vertical)
    }

    private func setupBindings() {
        playButton.rx.tap.bind(to: viewModel.event.playOrPauseTapped).disposed(by: bag)
        forwardButton.rx.tap.bind(to: viewModel.event.forward10SecondsTapped).disposed(by: bag)
        rewindButton.rx.tap.bind(to: viewModel.event.rewind10SecondsTapped).disposed(by: bag)

        speedSegmentedControl.rx.selectedSegmentIndex
            .map { index -> Float in
                switch index {
                case 0: return 0.5
                case 1: return 0.75
                case 2: return 1
                case 3: return 1.5
                case 4: return 2
                default: return 1
                }
            }
            .bind(to: viewModel.event.changeSpeed)
            .disposed(by: bag)

        slider.rx.value.bind(to: viewModel.event.changeAudioPosition).disposed(by: bag)

        viewModel.state.isReadyToPlay
            .distinctUntilChanged()
            .drive(with: self, onNext: { `self`, isReadyToPlay in self.setupUI(isReady: isReadyToPlay) })
            .disposed(by: bag)

        viewModel.state.isPlaying
            .drive(with: self, onNext: { `self`, isPlaying in
                let image = isPlaying ? self.pauseImage : self.playImage
                self.playButton.setImage(image, for: .normal)
            })
            .disposed(by: bag)

        viewModel.state.currentTime.drive(progressTimerLabel.rx.text).disposed(by: bag)
        viewModel.state.totalTime.drive(totalLengthLabel.rx.text).disposed(by: bag)

        viewModel.state.currentSeconds.drive(slider.rx.value).disposed(by: bag)
        viewModel.state.totalSeconds
            .drive(with: self, onNext: { `self`, seconds in
                self.slider.maximumValue = seconds
            })
            .disposed(by: bag)

        viewModel.state.loadingBufferRate.drive(slider.bufferProgressView.rx.progress).disposed(by: bag)

        viewModel.state.speedSegmentedControlAlpha.drive(speedSegmentedControl.rx.alpha).disposed(by: bag)
        viewModel.state.sliderAlpha.drive(slider.rx.alpha).disposed(by: bag)
    }

    private func setupUI(isReady: Bool) {
        playButton.isEnabled = isReady
        forwardButton.isEnabled = isReady
        rewindButton.isEnabled = isReady
        speedSegmentedControl.isEnabled = isReady
        slider.isEnabled = isReady
        if isReady == false {
            speedSegmentedControl.selectedSegmentIndex = 2
            slider.value = 0
            progressTimerLabel.text = ""
            totalLengthLabel.text = ""
        }
    }
}
