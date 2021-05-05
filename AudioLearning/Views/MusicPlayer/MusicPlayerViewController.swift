//
//  MusicPlayerViewController.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/12.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import RxSwift

final class MusicPlayerViewController: UIViewController, StoryboardGettable {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var speedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var slider: BufferingSlider!
    @IBOutlet weak var progressTimerLabel: UILabel!
    @IBOutlet weak var totalLengthLabel: UILabel!
    
    var viewModel: MusicPlayerViewModel!
    private let disposeBag = DisposeBag()
    
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
        NotificationCenter.default.rx
            .notification(.changeAppearance)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.setupUIColor()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUIColor() {
        let backgroundColor = Appearance.textColor
        let foreColor = Appearance.backgroundColor
        view.backgroundColor = backgroundColor
        let forwardImage = Appearance.mode == .dark ?
            UIImage(named: "forward-10") : UIImage(named: "forward-10-white")
        let rewindImage = Appearance.mode == .dark ?
            UIImage(named: "rewind-10") : UIImage(named: "rewind-10-white")
        forwardButton.setImage(forwardImage, for: UIControl.State())
        rewindButton.setImage(rewindImage, for: UIControl.State())
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
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|",
                                                        options: [], metrics: nil, views: views)
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|",
                                                      options: [], metrics: nil, views: views)
        view.addConstraints(horizontal + vertical)
    }
    
    private func setupBindings() {
        playButton.rx.tap
            .bind(to: viewModel.tappedPlayPause)
            .disposed(by: disposeBag)
        
        forwardButton.rx.tap
            .bind(to: viewModel.forward10Seconds)
            .disposed(by: disposeBag)
        rewindButton.rx.tap
            .bind(to: viewModel.rewind10Seconds)
            .disposed(by: disposeBag)
        speedSegmentedControl.rx.selectedSegmentIndex
            .map({ (index) -> Float in
                switch index {
                case 0: return 0.5
                case 1: return 0.75
                case 2: return 1
                case 3: return 1.5
                case 4: return 2
                default: return 1
                }
            })
            .bind(to: viewModel.changeSpeed)
            .disposed(by: disposeBag)
        slider.rx.value
            .bind(to: viewModel.changeAudioPosition)
            .disposed(by: disposeBag)
        
        viewModel.readyToPlay
            .drive(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.setupUI(isReady: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.isPlaying
            .drive(onNext: { [weak self] (isPlaying) in
                guard let `self` = self else { return }
                self.playButton.setImage(isPlaying ? self.pauseImage : self.playImage,
                                         for: UIControl.State())
            })
            .disposed(by: disposeBag)
        
        viewModel.currentTime
            .drive(progressTimerLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.totalTime
            .drive(totalLengthLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentSeconds
            .drive(slider.rx.value)
            .disposed(by: disposeBag)
        viewModel.totalSeconds
            .drive(onNext: { [weak self] (seconds) in
                guard let slider = self?.slider else { return }
                slider.maximumValue = seconds
            })
            .disposed(by: disposeBag)
        
        viewModel.loadingBufferRate
            .drive(slider.bufferProgressView.rx.progress)
            .disposed(by: disposeBag)
        
        viewModel.speedSegmentedControlAlpha
            .drive(speedSegmentedControl.rx.alpha)
            .disposed(by: disposeBag)
        
        viewModel.sliderAlpha
            .drive(slider.rx.alpha)
            .disposed(by: disposeBag)
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
