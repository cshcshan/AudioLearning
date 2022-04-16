//
//  BaseViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/10/15.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift
import RxTest
import XCTest
@testable import AudioLearning

class BaseViewModelTests: XCTestCase {

    var sut: BaseViewModel!

    var scheduler: TestScheduler!
    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        sut = BaseViewModel()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testShowEpisodeDetailFromPlaying() {
        let showEpisodeDetailFromPlaying = scheduler.createObserver(Void.self)
        sut.showEpisodeDetailFromPlaying
            .bind(to: showEpisodeDetailFromPlaying)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.tapPlaying)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(showEpisodeDetailFromPlaying.events.count, 2)
    }
}
