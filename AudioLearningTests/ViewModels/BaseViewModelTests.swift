//
//  BaseViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/10/15.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
@testable import AudioLearning

class BaseViewModelTests: XCTestCase {
    
    var sut: BaseViewModel!
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        sut = BaseViewModel()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testShowEpisodeDetailFromPlaying() {
        let showEpisodeDetailFromPlaying = scheduler.createObserver(Void.self)
        sut.showEpisodeDetailFromPlaying
            .bind(to: showEpisodeDetailFromPlaying)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ()),
                                        .next(20, ())])
            .bind(to: sut.tapPlaying)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(showEpisodeDetailFromPlaying.events.count, 2)
    }
}
