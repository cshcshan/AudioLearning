//
//  MusicPlayerViewModel.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/12.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import RxCocoa

class MusicPlayerViewModel {
    
    // Input
    private(set) var tappedPlayPause: AnyObserver<Void>
    private(set) var putNewAudio: AnyObserver<URL>
    private(set) var skipForward: AnyObserver<Int64>!
    private(set) var skipRewind: AnyObserver<Int64>!
    private(set) var speedUp: AnyObserver<Float>!
    private(set) var speedDown: AnyObserver<Float>!
    
    // Output
    private(set) var isPlaying: Driver<Bool>!
    private(set) var speedRate: Driver<Float>!
    private(set) var currentSeconds: Driver<Double>!
    private(set) var totalSeconds: Driver<Double>!
    private(set) var loadingBuffer: Driver<Double>!
    private(set) var loadingBufferPercent: Driver<Double>!
    
    private let disposeBag = DisposeBag()
    private var url: URL!
    private var player: HCAudioPlayerProtocol
    
    init(player: HCAudioPlayerProtocol) {
        self.player = player
        
        let putNewAudioSubject = PublishSubject<URL>()
        putNewAudio = putNewAudioSubject.asObserver()
        let tappedPlayPauseSubject = PublishSubject<Void>()
        tappedPlayPause = tappedPlayPauseSubject.asObserver()
        isPlaying = Observable.of(tappedPlayPauseSubject.asObservable().map({ $0 as AnyObject }),
                                  putNewAudioSubject.asObservable().map({ $0 as AnyObject }))
            .merge()
            .scan(false, accumulator: { [weak self] (aggregateValue, newValue) -> Bool in
                guard let `self` = self else { return false }
                if let url = newValue as? URL {
                    guard self.url != url else {
                        // if self.url == url, then isPlaying will not be affected
                        return aggregateValue
                    }
                    self.url = url
                    return false
                } else {
                    if self.url == nil {
                        return false
                    } else {
                        self.playMusic(!aggregateValue)
                        return !aggregateValue
                    }
                }
            })
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
        
        skipForward = player.skipForward
        skipRewind = player.skipRewind
        speedUp = player.speedUp
        speedDown = player.speedDown
        
        speedRate = player.speedRate
            .asDriver(onErrorJustReturn: 0)
        currentSeconds = player.currentSeconds
            .asDriver(onErrorJustReturn: 0)
        totalSeconds = player.totalSeconds
            .asDriver(onErrorJustReturn: 0)
        loadingBuffer = player.loadingBuffer
            .asDriver(onErrorJustReturn: 0)
        loadingBufferPercent = player.loadingBufferPercent
            .asDriver(onErrorJustReturn: 0)
    }
    
    private func playMusic(_ isPlay: Bool) {
        if isPlay {
            player.play.onNext(())
        } else {
            player.pause.onNext(())
        }
    }
}
