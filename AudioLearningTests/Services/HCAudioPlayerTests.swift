//
//  HCAudioPlayerTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/17.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import RxTest
import AVFoundation
import RxSwift
@testable import AudioLearning

class HCAudioPlayerTests: XCTestCase {
    
    var sut: HCAudioPlayer!
    var player: AVPlayer!
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        player = AVPlayer(url: Bundle.main.url(forResource: "190815_6min_english_cryptocurrency",
                                               withExtension: "mp3")!)
        sut = HCAudioPlayer(player: player)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        player = nil
        super.tearDown()
    }
    
//    func testInit_Speed_SpeedUp() {
//        let speedRate = scheduler.createObserver(Float.self)
//        sut.speedRate
//            .bind(to: speedRate)
//            .disposed(by: disposeBag)
//
//        scheduler.createHotObservable([.next(10, 0.25),
//                                       .next(20, 0.5),
//                                       .next(30, 0.75)])
//            .bind(to: sut.speedUp)
//            .disposed(by: disposeBag)
//
//        scheduler.start()
//
//        XCTAssertEqual(speedRate.events.count, 3)
//        XCTAssertEqual(speedRate.events, [.next(10, 1.25),
//                                          .next(20, 1.75),
//                                          .next(30, 2.5)])
//    }
//
//    func testInit_Speed_SpeedDown() {
//        let speedRate = scheduler.createObserver(Float.self)
//        sut.speedRate
//            .bind(to: speedRate)
//            .disposed(by: disposeBag)
//
//        scheduler.createHotObservable([.next(10, 0.25),
//                                       .next(20, 0.5),
//                                       .next(30, 0.75)])
//            .bind(to: sut.speedDown)
//            .disposed(by: disposeBag)
//
//        scheduler.start()
//
//        XCTAssertEqual(speedRate.events.count, 3)
//        XCTAssertEqual(speedRate.events, [.next(10, 0.75),
//                                          .next(20, 0.25),
//                                          .next(30, 0)])
//    }
}
