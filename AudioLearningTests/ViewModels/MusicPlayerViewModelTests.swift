//
//  MusicPlayerViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/12.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
import AVFoundation
@testable import AudioLearning

class MusicPlayerViewModelTests: XCTestCase {
    
    var sut: MusicPlayerViewModel!
    var player: MockHCAudioPlayer!
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        player = MockHCAudioPlayer()
        sut = MusicPlayerViewModel(player: player)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        player = nil
        super.setUp()
    }
}

// MARK: - isPlaying

extension MusicPlayerViewModelTests {
    
    // MARK: PlayOldAudio
    
    func testInit_IsPlaying_PlayNewAudio() {
        // Creates a MockObserver<Bool>
        let isPlaying = scheduler.createObserver(Bool.self)
        
        // Output combines with the MockObserver(isPlaying above)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: disposeBag)
        
        // MockObservable combines with Input
        let url1 = URL(string: "https://www.cshan.com/1")!
        let url2 = URL(string: "https://www.cshan.com/2")!
        scheduler.createHotObservable([.next(10, url1),
                                       .next(20, url2)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isPlaying.events.count, 3)
        XCTAssertEqual(isPlaying.events, [.next(0, false),
                                          .next(10, false),
                                          .next(20, false)])
    }
    
    func testInit_IsPlaying_TappedPlayPause() {
        // Creates a MockObserver<Bool>
        let isPlaying = scheduler.createObserver(Bool.self)
        
        // Output combines with the MockObserver(isPlaying above)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: disposeBag)
        
        // MockObservable combines with Input
        scheduler.createHotObservable([.next(10, ()),
                                       .next(20, ())])
            .bind(to: sut.tappedPlayPause)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isPlaying.events.count, 3)
        XCTAssertEqual(isPlaying.events, [.next(0, false),
                                          .next(10, false),
                                          .next(20, false)])
    }
    
    func testInit_IsPlaying_PlayNewAudioFirst_ThenTappedPlayPause() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: disposeBag)
        
        let url1 = URL(string: "https://www.cshan.com/1")!
        let url2 = URL(string: "https://www.cshan.com/2")!
        let url3 = URL(string: "https://www.cshan.com/3")!
        scheduler.createHotObservable([.next(5, url1),
                                       .next(15, url2),
                                       .next(25, url3)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: disposeBag)
        scheduler.createHotObservable([.next(10, ()),
                                       .next(20, ()),
                                       .next(30, ())])
            .bind(to: sut.tappedPlayPause)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isPlaying.events.count, 7)
        XCTAssertEqual(isPlaying.events, [.next(0, false),
                                          .next(5, false),
                                          .next(10, true),
                                          .next(15, false),
                                          .next(20, true),
                                          .next(25, false),
                                          .next(30, true)])
    }
    
    func testInit_IsPlaying_PlayNewAudioFirstTwoTimes_ThenTappedPlayPause() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: disposeBag)
        
        let url1 = URL(string: "https://www.cshan.com/1")!
        let url2 = URL(string: "https://www.cshan.com/2")!
        let url3 = URL(string: "https://www.cshan.com/3")!
        scheduler.createHotObservable([.next(5, url1),
                                       .next(15, url2),
                                       .next(25, url3)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: disposeBag)
        scheduler.createHotObservable([.next(20, ()),
                                       .next(30, ())])
            .bind(to: sut.tappedPlayPause)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isPlaying.events.count, 6)
        XCTAssertEqual(isPlaying.events, [.next(0, false),
                                          .next(5, false),
                                          .next(15, false),
                                          .next(20, true),
                                          .next(25, false),
                                          .next(30, true)])
    }
    
    func testInit_IsPlaying_PlayNewAudioFirst_ThenTappedPlayPauseTwoTimes() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: disposeBag)
        
        let url1 = URL(string: "https://www.cshan.com/1")!
        let url2 = URL(string: "https://www.cshan.com/2")!
        scheduler.createHotObservable([.next(5, url1),
                                       .next(25, url2)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: disposeBag)
        scheduler.createHotObservable([.next(10, ()),
                                       .next(20, ()),
                                       .next(30, ())])
            .bind(to: sut.tappedPlayPause)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isPlaying.events.count, 6)
        XCTAssertEqual(isPlaying.events, [.next(0, false),
                                          .next(5, false),
                                          .next(10, true),
                                          .next(20, false),
                                          .next(25, false),
                                          .next(30, true)])
    }
    
    func testInit_IsPlaying_TappedPlayPauseFirst_ThenPlayNewAudio() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: disposeBag)
        
        let url1 = URL(string: "https://www.cshan.com/1")!
        let url2 = URL(string: "https://www.cshan.com/2")!
        scheduler.createHotObservable([.next(15, url1),
                                       .next(25, url2)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: disposeBag)
        scheduler.createHotObservable([.next(10, ()),
                                       .next(20, ()),
                                       .next(30, ())])
            .bind(to: sut.tappedPlayPause)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isPlaying.events.count, 6)
        XCTAssertEqual(isPlaying.events, [.next(0, false),
                                          .next(10, false),
                                          .next(15, false),
                                          .next(20, true),
                                          .next(25, false),
                                          .next(30, true)])
    }
    
    // MARK: PlayOldAudio
    
    func testInit_IsPlaying_PlayOldAudio_ThenTappedPlayPause() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: disposeBag)
        
        let url1 = URL(string: "https://www.cshan.com/1")!
        scheduler.createHotObservable([.next(5, url1),
                                       .next(15, url1),
                                       .next(25, url1)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: disposeBag)
        scheduler.createHotObservable([.next(10, ()),
                                       .next(20, ()),
                                       .next(30, ())])
            .bind(to: sut.tappedPlayPause)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isPlaying.events.count, 7)
        XCTAssertEqual(isPlaying.events, [.next(0, false),
                                          .next(5, false),
                                          .next(10, true),
                                          .next(15, true),
                                          .next(20, false),
                                          .next(25, false),
                                          .next(30, true)])
    }
    
    func testInit_IsPlaying_PlayOldAudioTwoTimes_ThenTappedPlayPause_ThenPlayNewAudio() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: disposeBag)
        
        let url1 = URL(string: "https://www.cshan.com/1")!
        let url2 = URL(string: "https://www.cshan.com/2")!
        scheduler.createHotObservable([.next(5, url1),
                                       .next(15, url1),
                                       .next(25, url2)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: disposeBag)
        scheduler.createHotObservable([.next(10, ()),
                                       .next(20, ()),
                                       .next(30, ())])
            .bind(to: sut.tappedPlayPause)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isPlaying.events.count, 7)
        XCTAssertEqual(isPlaying.events, [.next(0, false),
                                          .next(5, false),
                                          .next(10, true),
                                          .next(15, true),
                                          .next(20, false),
                                          .next(25, false),
                                          .next(30, true)])
    }
}

// MARK: - Foward and Rewind

extension MusicPlayerViewModelTests {
    
    func testSkipForward_With10S() {
        player.musicCurrentSeconds = 20
        
        let currentTime = scheduler.createObserver(String.self)
        sut.currentTime
            .drive(currentTime)
            .disposed(by: disposeBag)
        
        scheduler.createHotObservable([.next(15, ())])
            .bind(to: sut.forward10Seconds)
            .disposed(by: disposeBag)
        
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(currentTime.events.count, 1)
        XCTAssertEqual(currentTime.events, [.next(15, "00:30")])
    }

    func testSkipRewind_With10S() {
        player.musicCurrentSeconds = 20
        
        let currentTime = scheduler.createObserver(String.self)
        sut.currentTime
            .drive(currentTime)
            .disposed(by: disposeBag)
        
        scheduler.createHotObservable([.next(15, ())])
            .bind(to: sut.rewind10Seconds)
            .disposed(by: disposeBag)
        
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(currentTime.events.count, 1)
        XCTAssertEqual(currentTime.events, [.next(15, "00:10")])
    }
}

// MARK: - Speed

extension MusicPlayerViewModelTests {
    
    func testChangeSpeed_AddHalf() {
        player.musicSpeedRate = 1
        
        let speedRate = scheduler.createObserver(Float.self)
        sut.speedRate
            .drive(speedRate)
            .disposed(by: disposeBag)
        
        scheduler.createHotObservable([.next(15, 0.5)])
            .bind(to: sut.speedUp)
            .disposed(by: disposeBag)
        
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(speedRate.events.count, 1)
        XCTAssertEqual(speedRate.events, [.next(15, 1.5)])
    }
    
    func testChangeSpeed_MinusHalf() {
        player.musicSpeedRate = 2
        
        let speedRate = scheduler.createObserver(Float.self)
        sut.speedRate
            .drive(speedRate)
            .disposed(by: disposeBag)
        
        scheduler.createHotObservable([.next(15, 0.5)])
            .bind(to: sut.speedDown)
            .disposed(by: disposeBag)
        
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(speedRate.events.count, 1)
        XCTAssertEqual(speedRate.events, [.next(15, 1.5)])
    }
}

// Change Audio Position

extension MusicPlayerViewModelTests {
    
    func testChangeAudioPosition() {
        player.musicCurrentSeconds = 10
        let currentSeconds = scheduler.createObserver(Float.self)
        sut.currentSeconds
            .drive(currentSeconds)
            .disposed(by: disposeBag)
        scheduler.createHotObservable([.next(10, 50),
                                       .next(15, 85)])
            .bind(to: sut.changeAudioPosition)
            .disposed(by: disposeBag)
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(currentSeconds.events.count, 2)
        XCTAssertEqual(currentSeconds.events, [.next(10, 50),
                                               .next(15, 85)])
    }
}
