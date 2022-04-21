//
//  AudioPlayerViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/12.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift

final class AudioPlayerViewModel {

    struct State {
        let isReadyToPlay: Driver<Bool>
        let isPlaying: Driver<Bool>
        let speedRate: Driver<Float>
        let currentTime: Driver<String>
        let totalTime: Driver<String>
        let currentSeconds: Driver<Float>
        let totalSeconds: Driver<Float>
        let loadingBufferRate: Driver<Float>
        let speedSegmentedControlAlpha: Driver<CGFloat>
        let sliderAlpha: Driver<CGFloat>
    }

    struct Event {
        let playOrPauseTapped = PublishRelay<Void>()
        let playNewAudio = PublishRelay<URL>()
        let forward10SecondsTapped = PublishRelay<Void>()
        let rewind10SecondsTapped = PublishRelay<Void>()
        let changeSpeed = PublishRelay<Float>() // will call 'change speed' when playing audio
        let changeAudioPosition = PublishRelay<Float>()

        let changeSpeedSegmentedControlAlpha = PublishRelay<CGFloat>()
        let changeSliderAlpha = PublishRelay<CGFloat>()
    }

    // MARK: - Properties

    let state: State
    let event = Event()

    private let defaultTimeString = "--:--"

    private let isReadyToPlay = BehaviorRelay<Bool>(value: false)
    private let isPlaying = BehaviorRelay<Bool>(value: false)
    private let speedRate = BehaviorRelay<Float>(value: 1)
    private let currentTime: BehaviorRelay<String>
    private let totalTime: BehaviorRelay<String>
    private let currentSeconds = BehaviorRelay<Float>(value: 0)
    private let totalSeconds = BehaviorRelay<Float>(value: 0)
    private let loadingBufferRate = BehaviorRelay<Float>(value: 0)

    private let bag = DisposeBag()

    private var url: URL!
    private var player: HCAudioPlayerProtocol

    init(player: HCAudioPlayerProtocol) {
        self.player = player

        self.currentTime = BehaviorRelay<String>(value: defaultTimeString)
        self.totalTime = BehaviorRelay<String>(value: defaultTimeString)
        self.state = State(
            isReadyToPlay: isReadyToPlay.asDriver(),
            isPlaying: isPlaying.asDriver(),
            speedRate: speedRate.asDriver(),
            currentTime: currentTime.asDriver(),
            totalTime: totalTime.asDriver(),
            currentSeconds: currentSeconds.asDriver(),
            totalSeconds: totalSeconds.asDriver(),
            loadingBufferRate: loadingBufferRate.asDriver(),
            speedSegmentedControlAlpha: event.changeSpeedSegmentedControlAlpha.asDriver(onErrorJustReturn: 1),
            sliderAlpha: event.changeSliderAlpha.asDriver(onErrorJustReturn: 1)
        )

        bind()
    }

    private func bind() {
        // event.playOrPauseTapped

        let playOrPauseTapped = event.playOrPauseTapped.withLatestFrom(isPlaying).share()

        let needsUpdatePlayStatus = playOrPauseTapped.filter { [weak self] _ in self?.url != nil }
        needsUpdatePlayStatus.filter { $0 }.map { _ in }.bind(to: player.event.playAudio).disposed(by: bag)
        needsUpdatePlayStatus.filter { !$0 }.map { _ in }.bind(to: player.event.pauseAudio).disposed(by: bag)

        let playOrPauseTappedResult = playOrPauseTapped
            .map { [weak self] isPlaying in self?.url == nil ? false : !isPlaying }

        // event.playNewAudio

        let needsUpdateNewAudio = event.playNewAudio
            .distinctUntilChanged()
            .filter { [weak self] url in url != self?.url }
            .share()

        needsUpdateNewAudio
            .do(onNext: { [weak self] url in self?.url = url })
            .bind(to: player.event.playNewAudio)
            .disposed(by: bag)

        let playNewAudioResult = needsUpdateNewAudio.map { _ in false }

        // player.status

        let playerStatusResult = player.state.status.asObservable().withLatestFrom(isPlaying) { status, isPlaying in
            status == .finish ? false : isPlaying
        }

        Observable
            .merge(playOrPauseTappedResult, playNewAudioResult, playerStatusResult)
            .do(onNext: { isPlaying in
                NotificationCenter.default.post(name: .isPlaying, object: nil, userInfo: ["isPlaying": isPlaying])
            })
            .bind(to: isPlaying)
            .disposed(by: bag)

        event.forward10SecondsTapped.map { _ in 10 }.bind(to: player.event.forwardAudio).disposed(by: bag)
        event.rewind10SecondsTapped.map { _ in 10 }.bind(to: player.event.rewindAudio).disposed(by: bag)

        Observable
            .combineLatest(
                isPlaying.asObservable(),
                event.changeSpeed.asObservable()
            )
            .filter { isPlaying, _ in isPlaying }
            .map { _, speedRate in speedRate }
            .bind(to: player.event.changeAudioSpeed)
            .disposed(by: bag)

        event.changeAudioPosition.bind(to: player.event.changeAudioPosition).disposed(by: bag)

        player.state.status.map { $0 == .readyToPlay }.distinctUntilChanged().drive(isReadyToPlay).disposed(by: bag)
        player.state.speedRate.drive(speedRate).disposed(by: bag)

        player.state.currentSeconds
            .map { [weak self, defaultTimeString] seconds -> String in
                self?.convertTime(seconds: seconds) ?? defaultTimeString
            }
            .drive(currentTime)
            .disposed(by: bag)

        player.state.totalSeconds
            .map { [weak self, defaultTimeString] seconds -> String in
                self?.convertTime(seconds: seconds) ?? defaultTimeString
            }
            .drive(totalTime)
            .disposed(by: bag)

        player.state.currentSeconds.map(Float.init).drive(currentSeconds).disposed(by: bag)
        player.state.totalSeconds.map(Float.init).drive(totalSeconds).disposed(by: bag)
        player.state.loadingBufferPercent.map { Float($0 / 100) }.drive(loadingBufferRate).disposed(by: bag)
    }

    private func convertTime(seconds: Double) -> String {
        guard !(seconds.isNaN || seconds.isInfinite) else { return "" }
        let minute = Int(seconds / 60)
        let second = Int(seconds.truncatingRemainder(dividingBy: 60))
        let minuteStr = String(format: "%02d", minute)
        let secondStr = String(format: "%02d", second)
        return "\(minuteStr):\(secondStr)"
    }
}
