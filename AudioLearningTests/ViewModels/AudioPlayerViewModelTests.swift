//
//  AudioPlayerViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/12.
//  Copyright © 2019 cshan. All rights reserved.
//

import AVFoundation
import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import AudioLearning

final class AudioPlayerViewModelTests: XCTestCase {

    var sut: AudioPlayerViewModel!
    var player: MockHCAudioPlayer!

    var scheduler: TestScheduler!
    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        player = MockHCAudioPlayer()
        sut = AudioPlayerViewModel(player: player)
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        player = nil
        super.setUp()
    }
}

// MARK: - isPlaying

extension AudioPlayerViewModelTests {

    // MARK: PlayOldAudio

    func testInit_IsPlaying_PlayNewAudio() {
        // Creates a MockObserver<Bool>
        let isPlaying = scheduler.createObserver(Bool.self)

        // Output combines with the MockObserver(isPlaying above)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: bag)

        // MockObservable combines with Input
        let url1 = URL(string: "https://www.cshan.com/1.mp3")!
        let url2 = URL(string: "https://www.cshan.com/2.mp3")!
        scheduler.createHotObservable([
            .next(10, url1),
            .next(20, url2)
        ])
        .bind(to: sut.settingNewAudio)
        .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isPlaying.events.count, 3)
        XCTAssertEqual(isPlaying.events, [
            .next(0, false),
            .next(10, false),
            .next(20, false)
        ])
    }

    func testInit_IsPlaying_TappedPlayPause() {
        // Creates a MockObserver<Bool>
        let isPlaying = scheduler.createObserver(Bool.self)

        // Output combines with the MockObserver(isPlaying above)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: bag)

        // MockObservable combines with Input
        scheduler.createHotObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.tappedPlayPause)
        .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isPlaying.events.count, 3)
        XCTAssertEqual(isPlaying.events, [
            .next(0, false),
            .next(10, false),
            .next(20, false)
        ])
    }

    func testInit_IsPlaying_PlayNewAudioFirst_ThenTappedPlayPause() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: bag)

        let url1 = URL(string: "https://www.cshan.com/1.mp3")!
        let url2 = URL(string: "https://www.cshan.com/2.mp3")!
        let url3 = URL(string: "https://www.cshan.com/3.mp3")!
        scheduler.createHotObservable([
            .next(5, url1),
            .next(15, url2),
            .next(25, url3)
        ])
        .bind(to: sut.settingNewAudio)
        .disposed(by: bag)
        scheduler.createHotObservable([
            .next(10, ()),
            .next(20, ()),
            .next(30, ())
        ])
        .bind(to: sut.tappedPlayPause)
        .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isPlaying.events.count, 7)
        XCTAssertEqual(isPlaying.events, [
            .next(0, false),
            .next(5, false),
            .next(10, true),
            .next(15, false),
            .next(20, true),
            .next(25, false),
            .next(30, true)
        ])
    }

    func testInit_IsPlaying_PlayNewAudioFirstTwoTimes_ThenTappedPlayPause() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: bag)

        let url1 = URL(string: "https://www.cshan.com/1.mp3")!
        let url2 = URL(string: "https://www.cshan.com/2.mp3")!
        let url3 = URL(string: "https://www.cshan.com/3.mp3")!
        scheduler.createHotObservable([
            .next(5, url1),
            .next(15, url2),
            .next(25, url3)
        ])
        .bind(to: sut.settingNewAudio)
        .disposed(by: bag)
        scheduler.createHotObservable([
            .next(20, ()),
            .next(30, ())
        ])
        .bind(to: sut.tappedPlayPause)
        .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isPlaying.events.count, 6)
        XCTAssertEqual(isPlaying.events, [
            .next(0, false),
            .next(5, false),
            .next(15, false),
            .next(20, true),
            .next(25, false),
            .next(30, true)
        ])
    }

    func testInit_IsPlaying_PlayNewAudioFirst_ThenTappedPlayPauseTwoTimes() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: bag)

        let url1 = URL(string: "https://www.cshan.com/1.mp3")!
        let url2 = URL(string: "https://www.cshan.com/2.mp3")!
        scheduler.createHotObservable([
            .next(5, url1),
            .next(25, url2)
        ])
        .bind(to: sut.settingNewAudio)
        .disposed(by: bag)
        scheduler.createHotObservable([
            .next(10, ()),
            .next(20, ()),
            .next(30, ())
        ])
        .bind(to: sut.tappedPlayPause)
        .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isPlaying.events.count, 6)
        XCTAssertEqual(isPlaying.events, [
            .next(0, false),
            .next(5, false),
            .next(10, true),
            .next(20, false),
            .next(25, false),
            .next(30, true)
        ])
    }

    func testInit_IsPlaying_TappedPlayPauseFirst_ThenPlayNewAudio() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: bag)

        let url1 = URL(string: "https://www.cshan.com/1.mp3")!
        let url2 = URL(string: "https://www.cshan.com/2.mp3")!
        scheduler.createHotObservable([
            .next(15, url1),
            .next(25, url2)
        ])
        .bind(to: sut.settingNewAudio)
        .disposed(by: bag)
        scheduler.createHotObservable([
            .next(10, ()),
            .next(20, ()),
            .next(30, ())
        ])
        .bind(to: sut.tappedPlayPause)
        .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isPlaying.events.count, 6)
        XCTAssertEqual(isPlaying.events, [
            .next(0, false),
            .next(10, false),
            .next(15, false),
            .next(20, true),
            .next(25, false),
            .next(30, true)
        ])
    }

    // MARK: PlayOldAudio

    func testInit_IsPlaying_PlayOldAudio_ThenTappedPlayPause() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: bag)

        let url1 = URL(string: "https://www.cshan.com/1.mp3")!
        scheduler.createHotObservable([
            .next(5, url1),
            .next(15, url1),
            .next(25, url1)
        ])
        .bind(to: sut.settingNewAudio)
        .disposed(by: bag)
        scheduler.createHotObservable([
            .next(10, ()),
            .next(20, ()),
            .next(30, ())
        ])
        .bind(to: sut.tappedPlayPause)
        .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isPlaying.events.count, 7)
        XCTAssertEqual(isPlaying.events, [
            .next(0, false),
            .next(5, false),
            .next(10, true),
            .next(15, true),
            .next(20, false),
            .next(25, false),
            .next(30, true)
        ])
    }

    func testInit_IsPlaying_PlayOldAudioTwoTimes_ThenTappedPlayPause_ThenPlayNewAudio() {
        let isPlaying = scheduler.createObserver(Bool.self)
        sut.isPlaying
            .drive(isPlaying)
            .disposed(by: bag)

        let url1 = URL(string: "https://www.cshan.com/1.mp3")!
        let url2 = URL(string: "https://www.cshan.com/2.mp3")!
        scheduler.createHotObservable([
            .next(5, url1),
            .next(15, url1),
            .next(25, url2)
        ])
        .bind(to: sut.settingNewAudio)
        .disposed(by: bag)
        scheduler.createHotObservable([
            .next(10, ()),
            .next(20, ()),
            .next(30, ())
        ])
        .bind(to: sut.tappedPlayPause)
        .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isPlaying.events.count, 7)
        XCTAssertEqual(isPlaying.events, [
            .next(0, false),
            .next(5, false),
            .next(10, true),
            .next(15, true),
            .next(20, false),
            .next(25, false),
            .next(30, true)
        ])
    }
}

// MARK: - Forward and Rewind

extension AudioPlayerViewModelTests {

    func testSkipForward_With10S() {
        player.audioCurrentSeconds = 20

        let currentTime = scheduler.createObserver(String.self)
        sut.currentTime
            .drive(currentTime)
            .disposed(by: bag)

        scheduler.createHotObservable([.next(15, ())])
            .bind(to: sut.forward10Seconds)
            .disposed(by: bag)

        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(currentTime.events.count, 1)
        XCTAssertEqual(currentTime.events, [.next(15, "00:30")])
    }

    func testSkipRewind_With10S() {
        player.audioCurrentSeconds = 20

        let currentTime = scheduler.createObserver(String.self)
        sut.currentTime
            .drive(currentTime)
            .disposed(by: bag)

        scheduler.createHotObservable([.next(15, ())])
            .bind(to: sut.rewind10Seconds)
            .disposed(by: bag)

        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(currentTime.events.count, 1)
        XCTAssertEqual(currentTime.events, [.next(15, "00:10")])
    }
}

// MARK: - Speed

extension AudioPlayerViewModelTests {

    func testChangeSpeed_AddHalf() {
        player.audioSpeedRate = 1

        let speedRate = scheduler.createObserver(Float.self)
        sut.speedRate
            .drive(speedRate)
            .disposed(by: bag)

        scheduler.createHotObservable([.next(15, 0.5)])
            .bind(to: sut.speedUp)
            .disposed(by: bag)

        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(speedRate.events.count, 1)
        XCTAssertEqual(speedRate.events, [.next(15, 1.5)])
    }

    func testChangeSpeed_MinusHalf() {
        player.audioSpeedRate = 2

        let speedRate = scheduler.createObserver(Float.self)
        sut.speedRate
            .drive(speedRate)
            .disposed(by: bag)

        scheduler.createHotObservable([.next(15, 0.5)])
            .bind(to: sut.speedDown)
            .disposed(by: bag)

        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(speedRate.events.count, 1)
        XCTAssertEqual(speedRate.events, [.next(15, 1.5)])
    }
}

// Change Speed

extension AudioPlayerViewModelTests {

    func testChangeSpeed_WhenIsNotPlaying() {
        player.audioSpeedRate = 1

        let speedRate = scheduler.createObserver(Float.self)
        sut.speedRate
            .drive(speedRate)
            .disposed(by: bag)
        scheduler.createHotObservable([
            .next(10, 2),
            .next(20, 3),
            .next(30, 0.5)
        ])
        .bind(to: sut.changeSpeed)
        .disposed(by: bag)
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(speedRate.events.count, 0)
    }

    func testChangeSpeed_WhenPlaying() {
        player.audioSpeedRate = 1

        let speedRate = scheduler.createObserver(Float.self)
        sut.speedRate
            .drive(speedRate)
            .disposed(by: bag)
        let url = URL(string: "https://www.cshan.com/1.mp3")!
        scheduler.createHotObservable([.next(5, url)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: bag)
        scheduler.createHotObservable([.next(10, ())])
            .bind(to: sut.tappedPlayPause)
            .disposed(by: bag)
        scheduler.createHotObservable([
            .next(20, 2),
            .next(30, 3),
            .next(40, 0.5)
        ])
        .bind(to: sut.changeSpeed)
        .disposed(by: bag)
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(speedRate.events.count, 3)
        XCTAssertEqual(speedRate.events, [
            .next(20, 2),
            .next(30, 3),
            .next(40, 0.5)
        ])
    }

    func testChangeSpeed_IsNotPlaying_ThenChangeSpeed_ThenPlay_ThenChangeSpeed() {
        player.audioSpeedRate = 1

        let speedRate = scheduler.createObserver(Float.self)
        sut.speedRate
            .drive(speedRate)
            .disposed(by: bag)
        let url = URL(string: "https://www.cshan.com/1.mp3")!
        // Change speed: clock 10 will not be called.
        scheduler.createHotObservable([
            .next(10, 2),
            .next(30, 3),
            .next(50, 0.5)
        ])
        .bind(to: sut.changeSpeed)
        .disposed(by: bag)
        // Play audio
        scheduler.createHotObservable([.next(35, url)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: bag)
        scheduler.createHotObservable([.next(40, ())])
            .bind(to: sut.tappedPlayPause)
            .disposed(by: bag)
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(speedRate.events.count, 2)
        XCTAssertEqual(speedRate.events, [
            .next(40, 3),
            .next(50, 0.5)
        ])
    }

    func testChangeSpeed_IsNotPlaying_ThenChangeSpeed_ThenPlay_ThenChangeSpeed_ThenPause_ThenChangeSpeed() {
        player.audioSpeedRate = 1

        let speedRate = scheduler.createObserver(Float.self)
        sut.speedRate
            .drive(speedRate)
            .disposed(by: bag)
        let url = URL(string: "https://www.cshan.com/1.mp3")!
        // Change speed: clock 10 will not be called.
        scheduler.createHotObservable([
            .next(10, 2),
            .next(30, 3),
            .next(50, 0.5)
        ])
        .bind(to: sut.changeSpeed)
        .disposed(by: bag)
        // Play audio
        scheduler.createHotObservable([.next(35, url)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: bag)
        scheduler.createHotObservable([
            .next(40, ()),
            .next(45, ())
        ])
        .bind(to: sut.tappedPlayPause)
        .disposed(by: bag)
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(speedRate.events.count, 1)
        XCTAssertEqual(speedRate.events, [.next(40, 3)])
    }

    func testChangeSpeed_IsNotPlaying_ThenChangeSpeed_ThenPlay_ThenChangeSpeed_ThenPause_ThenChangeSpeed_ThenPlay() {
        player.audioSpeedRate = 1

        let speedRate = scheduler.createObserver(Float.self)
        sut.speedRate
            .drive(speedRate)
            .disposed(by: bag)
        let url = URL(string: "https://www.cshan.com/1.mp3")!
        // Change speed: clock 10 will not be called.
        scheduler.createHotObservable([
            .next(10, 2),
            .next(30, 3),
            .next(50, 0.5)
        ])
        .bind(to: sut.changeSpeed)
        .disposed(by: bag)
        // Play audio
        scheduler.createHotObservable([.next(35, url)])
            .bind(to: sut.settingNewAudio)
            .disposed(by: bag)
        scheduler.createHotObservable([
            .next(40, ()),
            .next(45, ()),
            .next(55, ())
        ])
        .bind(to: sut.tappedPlayPause)
        .disposed(by: bag)
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(speedRate.events.count, 2)
        XCTAssertEqual(speedRate.events, [
            .next(40, 3),
            .next(55, 0.5)
        ])
    }
}

// Change Audio Position

extension AudioPlayerViewModelTests {

    func testChangeAudioPosition() {
        player.audioCurrentSeconds = 10
        let currentSeconds = scheduler.createObserver(Float.self)
        sut.currentSeconds
            .drive(currentSeconds)
            .disposed(by: bag)
        scheduler.createHotObservable([
            .next(10, 50),
            .next(15, 85)
        ])
        .bind(to: sut.changeAudioPosition)
        .disposed(by: bag)
        // execute merge putNewAudio and tappedPlayPause by isPlaying.drive()
        sut.isPlaying
            .drive()
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(currentSeconds.events.count, 2)
        XCTAssertEqual(currentSeconds.events, [
            .next(10, 50),
            .next(15, 85)
        ])
    }
}
