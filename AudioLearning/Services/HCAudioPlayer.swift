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
    // Inputs
    var newAudio: AnyObserver<URL>! { get }
    var play: AnyObserver<Void>! { get }
    var pause: AnyObserver<Void>! { get }
    var forward: AnyObserver<Int64>! { get }
    var rewind: AnyObserver<Int64>! { get }
    var speedUp: AnyObserver<Float>! { get }
    var speedDown: AnyObserver<Float>! { get }
    var changeSpeed: AnyObserver<Float>! { get }
    var changeAudioPosition: AnyObserver<Float>! { get }
    // Outputs
    var status: Observable<HCAudioPlayer.Status>! { get }
    var speedRate: Observable<Float>! { get }
    var currentSeconds: Observable<Double>! { get }
    var totalSeconds: Observable<Double>! { get }
    var loadingBuffer: Observable<Double>! { get }
    var loadingBufferPercent: Observable<Double>! { get }
}

final class HCAudioPlayer: NSObject, HCAudioPlayerProtocol {

    enum Status: Int {
        case unknown
        case readyToPlay
        case failed
        case finish
    }

    // Inputs
    private(set) var newAudio: AnyObserver<URL>!
    private(set) var play: AnyObserver<Void>!
    private(set) var pause: AnyObserver<Void>!
    private(set) var forward: AnyObserver<Int64>!
    private(set) var rewind: AnyObserver<Int64>!
    private(set) var speedUp: AnyObserver<Float>!
    private(set) var speedDown: AnyObserver<Float>!
    private(set) var changeSpeed: AnyObserver<Float>!
    private(set) var changeAudioPosition: AnyObserver<Float>!

    // Outputs
    private(set) var status: Observable<HCAudioPlayer.Status>!
    private(set) var speedRate: Observable<Float>!
    private(set) var currentSeconds: Observable<Double>!
    private(set) var totalSeconds: Observable<Double>!
    private(set) var loadingBuffer: Observable<Double>!
    private(set) var loadingBufferPercent: Observable<Double>!

    private let statusSubject = PublishSubject<HCAudioPlayer.Status>()
    private let currentSecondsSubject = PublishSubject<Double>()
    private let totalSecondsSubject = PublishSubject<Double>()
    private let loadingBufferSubject = PublishSubject<Double>()
    private let loadingBufferPercentSubject = PublishSubject<Double>()

    private var player: AVPlayer?
    private var item: AVPlayerItem?
    private let disposeBag = DisposeBag()

    override init() {
        super.init()
        setupAudioSessionCategory()
        setupInputs()
        setupOutputs()
    }

    deinit {
        removeItemObservers()
    }

    private func setupAudioSessionCategory() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .allowAirPlay)
    }

    private func setupInputs() {
        // New Music
        let newAudioSubject = PublishSubject<URL>()
        newAudio = newAudioSubject.asObserver()
        newAudioSubject
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self.setupPlayer(AVPlayer(url: url))
            })
            .disposed(by: disposeBag)

        // Play and Pause
        let playSubject = PublishSubject<Void>()
        play = playSubject.asObserver()
        let pauseSubject = PublishSubject<Void>()
        pause = pauseSubject.asObserver()
        Observable.of(
            playSubject.map { true },
            pauseSubject.map { false }
        )
        .merge()
        .subscribe(onNext: { [weak self] isPlay in
            guard let player = self?.player else { return }
            if isPlay {
                player.play()
            } else {
                player.pause()
            }
        })
        .disposed(by: disposeBag)

        // Forward and Rewind
        let forwardSubject = PublishSubject<Int64>()
        forward = forwardSubject.asObserver()
        let rewindSubject = PublishSubject<Int64>()
        rewind = rewindSubject.asObserver()
        Observable.of(
            forwardSubject.asObservable(),
            rewindSubject.asObservable().map { -$0 }
        )
        .merge()
        .subscribe(onNext: { [weak self] seconds in
            guard let player = self?.player else { return }
            let currentTime = CMTimeGetSeconds(player.currentTime())
            player.seek(to: CMTime(value: CMTimeValue(currentTime) + seconds, timescale: 1))
        })
        .disposed(by: disposeBag)

        // Speed Up and Down
        let speedUpSubject = PublishSubject<Float>()
        speedUp = speedUpSubject.asObserver()
        let speedDownSubject = PublishSubject<Float>()
        speedDown = speedDownSubject.asObserver()
        speedRate = Observable.of(
            speedUpSubject.asObservable(),
            speedDownSubject.asObservable().map { -$0 }
        )
        .merge()
        .map { [weak self] rate -> Float in
            guard let player = self?.player else { return 1 }
            player.rate += rate
            if player.rate < 0 { player.rate = 0 }
            return player.rate
        }

        // Change Speed
        let changeSpeedSubject = PublishSubject<Float>()
        changeSpeed = changeSpeedSubject.asObserver()
        changeSpeedSubject
            .subscribe(onNext: { [weak self] speedRate in
                guard let player = self?.player else { return }
                player.rate = speedRate
            })
            .disposed(by: disposeBag)

        // Change Audio Location
        let changeAudioLocationSubject = PublishSubject<Float>()
        changeAudioPosition = changeAudioLocationSubject.asObserver()
        changeAudioLocationSubject
            .subscribe(onNext: { [weak self] position in
                guard let player = self?.player else { return }
                player.seek(to: CMTime(value: CMTimeValue(position), timescale: 1))
            })
            .disposed(by: disposeBag)
    }

    private func setupOutputs() {
        status = statusSubject.asObservable()
        currentSeconds = currentSecondsSubject.asObservable()
        totalSeconds = totalSecondsSubject.asObservable()
        loadingBuffer = loadingBufferSubject.asObservable()
        loadingBufferPercent = loadingBufferPercentSubject.asObservable()
    }
}

extension HCAudioPlayer {

    private func setupPlayer(_ player: AVPlayer) {
        if item != nil { removeItemObservers() }

        self.player = player
        item = player.currentItem

        addPlayerObservers()
        addItemObservers()
    }

    private func addPlayerObservers() {
        guard let player = player else { return }
        player
            .addPeriodicTimeObserver(
                forInterval: CMTime(value: 1, timescale: 1),
                queue: DispatchQueue.main
            ) { [weak self] time in
                guard let self = self else { return }
                self.currentSecondsSubject.onNext(CMTimeGetSeconds(time))
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
        statusSubject.onNext(.finish)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == ObserverKey.status.rawValue {
            guard let player = player else { return }
            let playerStatus = HCAudioPlayer.Status(rawValue: player.status.rawValue) ?? HCAudioPlayer.Status.unknown
            statusSubject.onNext(playerStatus)
            if player.status == .readyToPlay {
                guard let item = player.currentItem else { return }
                currentSecondsSubject.onNext(0)
                totalSecondsSubject.onNext(CMTimeGetSeconds(item.duration))
            }
        } else if keyPath == ObserverKey.loadedTimeRanges.rawValue {
            guard let item = player?.currentItem else { return }
            guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else { return }
            let duration = CMTimeGetSeconds(item.duration)
            let buffer = CMTimeGetSeconds(timeRange.start + timeRange.duration)
            let percent = 100 * buffer / duration
            loadingBufferSubject.onNext(buffer)
            loadingBufferPercentSubject.onNext(percent)
        }
    }
}
