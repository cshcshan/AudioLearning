//
//  HCAudioPlayer.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/16.
//  Copyright © 2019 cshan. All rights reserved.
//

import AVFoundation
import Foundation
import RxCocoa
import RxSwift

private enum ObserverKey: String {
    case status
    case loadedTimeRanges
}

protocol HCAudioPlayerProtocol {
    var state: HCAudioPlayerState { get }
    var event: HCAudioPlayerEvent { get }
}

struct HCAudioPlayerState {
    let status: Driver<HCAudioPlayer.Status>
    let speedRate: Driver<Float>
    let currentSeconds: Driver<Double>
    let totalSeconds: Driver<Double>
    let loadingBuffer: Driver<Double>
    let loadingBufferPercent: Driver<Double>
}

struct HCAudioPlayerEvent {
    let playNewAudio = PublishRelay<URL>()
    let playAudio = PublishRelay<Void>()
    let pauseAudio = PublishRelay<Void>()
    let forwardAudio = PublishRelay<Int64>()
    let rewindAudio = PublishRelay<Int64>()
    let speedAudioUp = PublishRelay<Float>()
    let speedAudioDown = PublishRelay<Float>()
    let changeAudioSpeed = PublishRelay<Float>()
    let changeAudioPosition = PublishRelay<Float>()
}

final class HCAudioPlayer: NSObject, HCAudioPlayerProtocol {

    enum Status: Int {
        case unknown
        case readyToPlay
        case failed
        case finish
    }

    lazy var state = HCAudioPlayerState(
        status: status.asDriver(),
        speedRate: speedRate.asDriver(),
        currentSeconds: currentSeconds.asDriver(),
        totalSeconds: totalSeconds.asDriver(),
        loadingBuffer: loadingBuffer.asDriver(),
        loadingBufferPercent: loadingBufferPercent.asDriver()
    )

    let event = HCAudioPlayerEvent()

    private let status = BehaviorRelay<HCAudioPlayer.Status>(value: .unknown)
    private let speedRate = BehaviorRelay<Float>(value: 1.0)
    private let currentSeconds = BehaviorRelay<Double>(value: 0.0)
    private let totalSeconds = BehaviorRelay<Double>(value: 0.0)
    private let loadingBuffer = BehaviorRelay<Double>(value: 0.0)
    private let loadingBufferPercent = BehaviorRelay<Double>(value: 0.0)

    private var player: AVPlayer?
    private var item: AVPlayerItem?
    private let bag = DisposeBag()

    override init() {
        super.init()
        setupAudioSessionCategory()
        setupInputs()
    }

    deinit {
        removeItemObservers()
    }

    private func setupAudioSessionCategory() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .allowAirPlay)
    }

    private func setupInputs() {
        event.playNewAudio.asSignal()
            .emit(with: self, onNext: { `self`, url in self.setupPlayer(AVPlayer(url: url)) })
            .disposed(by: bag)

        // Play and Pause
        event.playAudio
            .subscribe(onNext: { [player] _ in player?.play() })
            .disposed(by: bag)

        event.pauseAudio
            .subscribe(onNext: { [player] _ in player?.pause() })
            .disposed(by: bag)

        // Forward and Rewind
        Observable
            .merge(event.forwardAudio.asObservable(), event.rewindAudio.map { -$0 })
            .subscribe(onNext: { [weak self] seconds in
                guard let player = self?.player else { return }
                let currentTime = CMTimeGetSeconds(player.currentTime())
                player.seek(to: CMTime(value: CMTimeValue(currentTime) + seconds, timescale: 1))
            })
            .disposed(by: bag)

        // Speed Up and Down
        Observable
            .merge(event.speedAudioUp.asObservable(), event.speedAudioDown.map { $0 })
            .map { [player] rate -> Float in
                guard let player = player else { return 1 }
                player.rate += rate
                player.rate = max(player.rate, 0) // minimum is 0
                return player.rate
            }
            .bind(to: speedRate)
            .disposed(by: bag)

        // Change Speed
        event.changeAudioSpeed
            .subscribe(onNext: { [player] speedRate in player?.rate = speedRate })
            .disposed(by: bag)

        // Change Audio Location
        event.changeAudioPosition
            .subscribe(onNext: { [player] position in
                player?.seek(to: CMTime(value: CMTimeValue(position), timescale: 1))
            })
            .disposed(by: bag)
    }
}

extension HCAudioPlayer {

    private func setupPlayer(_ player: AVPlayer) {
        guard item == nil else {
            return removeItemObservers()
        }

        self.player = player
        item = player.currentItem

        addPlayerObservers()
        addItemObservers()
    }

    private func addPlayerObservers() {
        player?.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: 1),
            queue: DispatchQueue.main
        ) { [weak self] time in
            self?.currentSeconds.accept(CMTimeGetSeconds(time))
        }
    }

    private func addItemObservers() {
        guard let item = item else { return }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioFinished),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: item
        )

        item.addObserver(self, forKeyPath: ObserverKey.status.rawValue, options: .new, context: nil)
        item.addObserver(self, forKeyPath: ObserverKey.loadedTimeRanges.rawValue, options: .new, context: nil)
    }

    private func removeItemObservers() {
        guard let item = item else { return }

        item.removeObserver(self, forKeyPath: ObserverKey.status.rawValue)
        item.removeObserver(self, forKeyPath: ObserverKey.loadedTimeRanges.rawValue)
    }

    @objc func audioFinished(notification: Notification) {
        guard let item = item else { return }
        item.seek(to: .zero, completionHandler: nil)
        status.accept(.finish)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        switch keyPath {
        case ObserverKey.status.rawValue:
            guard let player = player else { return }

            let playerStatus = HCAudioPlayer.Status(rawValue: player.status.rawValue) ?? HCAudioPlayer.Status.unknown
            status.accept(playerStatus)

            if player.status == .readyToPlay {
                guard let item = player.currentItem else { return }
                currentSeconds.accept(0)
                totalSeconds.accept(CMTimeGetSeconds(item.duration))
            }
        case ObserverKey.loadedTimeRanges.rawValue:
            guard let item = player?.currentItem,
                  let timeRange = item.loadedTimeRanges.first?.timeRangeValue
            else { return }

            let duration = CMTimeGetSeconds(item.duration)
            let buffer = CMTimeGetSeconds(timeRange.start + timeRange.duration)
            let percent = 100 * buffer / duration

            loadingBuffer.accept(buffer)
            loadingBufferPercent.accept(percent)
        case .none, .some:
            break
        }
    }
}
