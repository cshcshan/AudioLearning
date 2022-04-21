//
//  MockHCAudioPlayer.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/17.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxCocoa
import RxSwift
@testable import AudioLearning

final class MockHCAudioPlayer: HCAudioPlayerProtocol {

    // MARK: - Properties

    lazy var state = HCAudioPlayerState(
        status: status.asDriver(),
        speedRate: speedRate.asDriver(),
        currentSeconds: currentSeconds.asDriver(),
        totalSeconds: totalSeconds.asDriver(),
        loadingBuffer: loadingBuffer.asDriver(),
        loadingBufferPercent: loadingBufferPercent.asDriver()
    )

    let event = HCAudioPlayerEvent()

    private(set) lazy var status = BehaviorRelay<HCAudioPlayer.Status>(value: .unknown)
    private(set) lazy var speedRate = BehaviorRelay<Float>(value: 1.0)
    private(set) lazy var currentSeconds = BehaviorRelay<Double>(value: 0.0)
    private(set) lazy var totalSeconds = BehaviorRelay<Double>(value: audioTotalSeconds)
    private(set) lazy var loadingBuffer = BehaviorRelay<Double>(value: 0.0)
    private(set) lazy var loadingBufferPercent = BehaviorRelay<Double>(value: 0.0)

    private let bag = DisposeBag()

    // Results
    var audioURL = PublishSubject<URL>()
    var audioCurrentSeconds: Double = 0
    var audioTotalSeconds: Double = 100
    var audioSpeedRate: Float = 1

    init() {
        setupInputs()
    }

    private func setupInputs() {
        // Forward and Rewind
        Observable
            .merge(event.forwardAudio.asObservable(), event.rewindAudio.map { -$0 })
            .map { [weak self] seconds in
                var audioCurrentSeconds = self?.audioCurrentSeconds ?? 0.0
                let audioTotalSeconds = self?.audioTotalSeconds ?? 0.0
                audioCurrentSeconds += Double(seconds)
                audioCurrentSeconds = min(max(audioCurrentSeconds, 0.0), audioTotalSeconds)
                self?.audioCurrentSeconds = audioCurrentSeconds
                return audioCurrentSeconds
            }
            .bind(to: currentSeconds)
            .disposed(by: bag)

        // Speed Up and Down
        Observable
            .merge(event.speedAudioUp.asObservable(), event.speedAudioDown.map { -$0 })
            .map { [audioSpeedRate] rate -> Float in
                var audioSpeedRate = audioSpeedRate
                audioSpeedRate += rate
                audioSpeedRate = max(audioSpeedRate, 0)
                return audioSpeedRate
            }
            .bind(to: speedRate)
            .disposed(by: bag)

        // Change Speed
        event.changeAudioSpeed.bind(to: speedRate).disposed(by: bag)

        // Change Audio Position
        event.changeAudioPosition.map(Double.init).bind(to: currentSeconds).disposed(by: bag)
    }

    private func reset() {
        audioCurrentSeconds = 0
        audioTotalSeconds = 100
        audioSpeedRate = 1
    }
}
