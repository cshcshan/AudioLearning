//
//  MockHCAudioPlayer.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/17.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
@testable import AudioLearning

class MockHCAudioPlayer: HCAudioPlayerProtocol {
    
    // Inputs
    var newAudio: AnyObserver<URL>!
    var play: AnyObserver<Void>!
    var pause: AnyObserver<Void>!
    var forward: AnyObserver<Int64>!
    var rewind: AnyObserver<Int64>!
    var speedUp: AnyObserver<Float>!
    var speedDown: AnyObserver<Float>!
    var changeAudioPosition: AnyObserver<Float>!
    
    // Outputs
    var status: Observable<HCAudioPlayer.Status>!
    var speedRate: Observable<Float>!
    var currentSeconds: Observable<Double>!
    var totalSeconds: Observable<Double>!
    var loadingBuffer: Observable<Double>!
    var loadingBufferPercent: Observable<Double>!
    
    private let currentSecondsSubject = PublishSubject<Double>()
    private let totalSecondsSubject = PublishSubject<Double>()
    
    private let disposeBag = DisposeBag()
    
    // Results
    var musicUrl = PublishSubject<URL>()
    var musicCurrentSeconds: Double = 0
    var musicTotalSeconds: Double = 100
    var musicSpeedRate: Float = 1
    
    init() {
        setupInputs()
        setupOutputs()
    }
    
    private func setupInputs() {
        // New Music
        let newAudioSubject = PublishSubject<URL>()
        newAudio = newAudioSubject.asObserver()
        
        // Play and Pause
        let playSubject = PublishSubject<Void>()
        play = playSubject.asObserver()
        let pauseSubject = PublishSubject<Void>()
        pause = pauseSubject.asObserver()
        _ = Observable.of(playSubject.map({ true }),
                              pauseSubject.map({ false })).merge()
        
        // Forward and Rewind
        let forwardSubject = PublishSubject<Int64>()
        forward = forwardSubject.asObserver()
        let rewindSubject = PublishSubject<Int64>()
        rewind = rewindSubject.asObserver()
        let mergeSkip = Observable.of(forwardSubject.asObservable(),
                                      rewindSubject.asObservable().map({ -$0 })).merge()
        mergeSkip
            .subscribe(onNext: { [weak self] (seconds) in
                guard let `self` = self else { return }
                self.musicCurrentSeconds += Double(seconds)
                self.currentSecondsSubject.onNext(self.musicCurrentSeconds)
            })
            .disposed(by: disposeBag)
        
        // Speed Up and Down
        let speedUpSubject = PublishSubject<Float>()
        speedUp = speedUpSubject.asObserver()
        let speedDownSubject = PublishSubject<Float>()
        speedDown = speedDownSubject.asObserver()
        speedRate = Observable.of(speedUpSubject.asObservable(),
                                  speedDownSubject.asObservable().map({ -$0 }))
            .merge()
            .map({ [weak self] (rate) -> Float in
                guard let `self` = self else { return 1 }
                self.musicSpeedRate += rate
                if self.musicSpeedRate < 0 { self.musicSpeedRate = 0 }
                return self.musicSpeedRate
            })
        
        // Change Audio Position
        let changeAudioPositionSubject = PublishSubject<Float>()
        changeAudioPosition = changeAudioPositionSubject.asObserver()
        changeAudioPositionSubject
            .subscribe(onNext: { [weak self] (position) in
                guard let `self` = self else { return }
                self.currentSecondsSubject.onNext(Double(position))
            })
            .disposed(by: disposeBag)
    }
    
    private func setupOutputs() {
        let statusSubject = PublishSubject<HCAudioPlayer.Status>()
        status = statusSubject.asObservable()
        
        currentSeconds = currentSecondsSubject.asObservable()
        totalSeconds = totalSecondsSubject.asObservable()
        totalSecondsSubject.onNext(musicTotalSeconds)
        
        let loadingBufferSubject = PublishSubject<Double>()
        loadingBuffer = loadingBufferSubject.asObservable()
        
        let loadingBufferPercentSubject = PublishSubject<Double>()
        loadingBufferPercent = loadingBufferPercentSubject.asObservable()
    }
    
    private func reset() {
        musicCurrentSeconds = 0
        musicTotalSeconds = 100
        musicSpeedRate = 1
    }
}
