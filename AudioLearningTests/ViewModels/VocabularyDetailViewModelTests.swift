//
//  VocabularyDetailViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import RealmSwift
import RxTest
import RxSwift
import RxCocoa
@testable import AudioLearning

class VocabularyDetailViewModelTests: XCTestCase {
    
    var sut: VocabularyDetailViewModel!
    var realmService: RealmService<VocabularyRealmModel>!
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        realmService = RealmService()
        sut = VocabularyDetailViewModel(realmService: realmService)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        sut = nil
        realmService = nil
        super.tearDown()
    }
    
    func testInit_Word() {
        let model190815 = VocabularyRealmModel()
        model190815.episode = "Episode 190815"
        model190815.word = "Apple"
        model190815.note = "蘋果🍎"
        model190815.updateDate = Date()
        
        let model190822 = VocabularyRealmModel()
        model190822.episode = "Episode 190822"
        model190822.word = "Phone"
        model190822.note = "手機📱"
        model190822.updateDate = Date()
        
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, model190815),
                                        .next(20, model190822)])
            .bind(to: sut.load)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 3)
        XCTAssertEqual(word.events, [.next(0, ""),
                                     .next(10, "Apple"),
                                     .next(20, "Phone")])
    }
    
    func testInit_Note() {
        let model190815 = VocabularyRealmModel()
        model190815.episode = "Episode 190815"
        model190815.word = "Apple"
        model190815.note = "蘋果🍎"
        model190815.updateDate = Date()
        
        let model190822 = VocabularyRealmModel()
        model190822.episode = "Episode 190822"
        model190822.word = "Phone"
        model190822.note = "手機📱"
        model190822.updateDate = Date()
        
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, model190815),
                                        .next(20, model190822)])
            .bind(to: sut.load)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 3)
        XCTAssertEqual(note.events, [.next(0, ""),
                                     .next(10, "蘋果🍎"),
                                     .next(20, "手機📱")])
    }
    
    func testClose_FromSave() {
        let model190815 = VocabularyRealmModel()
        model190815.episode = "Episode 190815"
        model190815.word = "Apple"
        model190815.note = "蘋果🍎"
        model190815.updateDate = Date()
        
        let close = scheduler.createObserver(Void.self)
        sut.close
            .bind(to: close)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, model190815)])
            .bind(to: sut.save)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(close.events.count, 1)
    }
    
    func testClose_FromCancel() {
        let close = scheduler.createObserver(Void.self)
        sut.close
            .bind(to: close)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.cancel)
            .disposed(by: disposeBag)
        scheduler.start()
        XCTAssertEqual(close.events.count, 1)
    }
}
