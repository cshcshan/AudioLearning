//
//  VocabularyDetailViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/23.
//  Copyright © 2019 cshan. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import AudioLearning

class VocabularyDetailViewModelTests: XCTestCase {

    var sut: VocabularyDetailViewModel!
    var realmService: RealmService<VocabularyRealm>!

    var scheduler: TestScheduler!
    var bag: DisposeBag!

    private let realmModel190815 = VocabularyRealm()
    private let realmModel190822 = VocabularyRealm()
    private var saveModel190815: VocabularySaveModel!
    private var saveModel190822: VocabularySaveModel!

    override func setUp() {
        super.setUp()
        setupRealm()
        realmService = RealmService<VocabularyRealm>()
        initStub()
        setupModels()
        sut = VocabularyDetailViewModel(realmService: realmService)
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        flushData()
        sut = nil
        realmService = nil
        super.tearDown()
    }
}

// MARK: - Word and Note

extension VocabularyDetailViewModelTests {

    func testWord_FromLoad() {
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, realmModel190815),
            .next(20, realmModel190822)
        ])
        .bind(to: sut.load)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 3)
        XCTAssertEqual(word.events, [
            .next(0, ""),
            .next(10, "Apple"),
            .next(20, "Phone")
        ])
    }

    func testWord_FromAdd() {
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.add)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 3)
        XCTAssertEqual(word.events, [
            .next(0, ""),
            .next(10, ""),
            .next(20, "")
        ])
    }

    func testWord_FromAddWithWord() {
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, (nil, "Hello")),
            .next(20, (nil, "World"))
        ])
        .bind(to: sut.addWithWord)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 3)
        XCTAssertEqual(word.events, [
            .next(0, ""),
            .next(10, "Hello"),
            .next(20, "World")
        ])
    }

    func testWord_FromLoad_ThenAdd_ThenAddWithWord() {
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, (nil, "Hello"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, ""),
            .next(10, "Apple"),
            .next(20, ""),
            .next(30, "Hello")
        ])
    }

    func testWord_FromAdd_ThenAddWithWord_ThenLoad() {
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, (nil, "Hello"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, ""),
            .next(10, ""),
            .next(20, "Hello"),
            .next(30, "Apple")
        ])
    }

    func testWord_FromAddWithWord_ThenLoad_ThenAdd() {
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, (nil, "Hello"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, ""),
            .next(10, "Hello"),
            .next(20, "Apple"),
            .next(30, "")
        ])
    }

    func testWord_FromAddWithWord_ThenAdd_ThenLoad() {
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, (nil, "Hello"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, ""),
            .next(10, "Hello"),
            .next(20, ""),
            .next(30, "Apple")
        ])
    }

    func testWord_FromAdd_ThenLoad_ThenAddWithWord() {
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, (nil, "Hello"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, ""),
            .next(10, ""),
            .next(20, "Apple"),
            .next(30, "Hello")
        ])
    }

    func testWord_FromLoad_ThenAddWithWord_ThenAdd() {
        let word = scheduler.createObserver(String.self)
        sut.word
            .bind(to: word)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, (nil, "Hello"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, ""),
            .next(10, "Apple"),
            .next(20, "Hello"),
            .next(30, "")
        ])
    }

    func testNote_FromLoad() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, realmModel190815),
            .next(20, realmModel190822)
        ])
        .bind(to: sut.load)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 3)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, "蘋果🍎"),
            .next(20, "手機📱")
        ])
    }

    func testNote_FromAdd() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.add)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 3)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, ""),
            .next(20, "")
        ])
    }

    func testNote_FromAddWithWord() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, (nil, "Hello 1")),
            .next(20, (nil, "Hello 2"))
        ])
        .bind(to: sut.addWithWord)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 5)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, ""),
            .next(10, "World 1"),
            .next(20, ""),
            .next(20, "World 2")
        ])
    }

    func testNote_FromAddWithWordNotFound() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, (nil, "Hello")),
            .next(20, (nil, "World"))
        ])
        .bind(to: sut.addWithWord)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 3)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, ""),
            .next(20, "")
        ])
    }

    func testNote_FromLoad_ThenAdd_ThenAddWithWord_ThenAddWithWordNotFound() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, (nil, "Hello 1"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(40, (nil, "Not Found"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, "蘋果🍎"),
            .next(20, ""),
            .next(30, ""),
            .next(30, "World 1"),
            .next(40, "")
        ])
    }

    func testNote_FromAdd_ThenAddWithWord_ThenAddWithWordNotFound_ThenLoad() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, (nil, "Hello 1"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, (nil, "Not Found"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(40, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, ""),
            .next(20, ""),
            .next(20, "World 1"),
            .next(30, ""),
            .next(40, "蘋果🍎")
        ])
    }

    func testNote_FromAddWithWord_ThenAddWithWordNotFound_ThenLoad_ThenAdd() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, (nil, "Hello 1"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, (nil, "Not Found"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(40, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, ""),
            .next(10, "World 1"),
            .next(20, ""),
            .next(30, "蘋果🍎"),
            .next(40, "")
        ])
    }

    func testNote_FromAddWithWordNotFound_ThenLoad_ThenAdd_ThenAddWithWord() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, (nil, "Not Found"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(40, (nil, "Hello 1"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, ""),
            .next(20, "蘋果🍎"),
            .next(30, ""),
            .next(40, ""),
            .next(40, "World 1")
        ])
    }

    func testNote_FromAddWithWordNotFound_ThenAddWithWord_ThenAdd_ThenLoad() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, (nil, "Not Found"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, (nil, "Hello 1"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(40, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, ""),
            .next(20, ""),
            .next(20, "World 1"),
            .next(30, ""),
            .next(40, "蘋果🍎")
        ])
    }

    func testNote_FromAddWithWord_ThenAdd_ThenLoad_ThenAddWithWordNotFound() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, (nil, "Hello 1"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(40, (nil, "Not Found"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, ""),
            .next(10, "World 1"),
            .next(20, ""),
            .next(30, "蘋果🍎"),
            .next(40, "")
        ])
    }

    func testNote_FromAdd_ThenLoad_ThenAddWithWordNotFound_ThenAddWithWord() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, (nil, "Not Found"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(40, (nil, "Hello 1"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, ""),
            .next(20, "蘋果🍎"),
            .next(30, ""),
            .next(40, ""),
            .next(40, "World 1")
        ])
    }

    func testNote_FromLoad_ThenAddWithWordNotFound_ThenAddWithWord_ThenAdd() {
        let note = scheduler.createObserver(String.self)
        sut.note
            .bind(to: note)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, realmModel190815)])
            .bind(to: sut.load)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(20, (nil, "Not Found"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(30, (nil, "Hello 1"))])
            .bind(to: sut.addWithWord)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(40, ())])
            .bind(to: sut.add)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, ""),
            .next(10, "蘋果🍎"),
            .next(20, ""),
            .next(30, ""),
            .next(30, "World 1"),
            .next(40, "")
        ])
    }
}

// MARK: - Save and Close

extension VocabularyDetailViewModelTests {

    func testSaved() {
        let saved = scheduler.createObserver(Void.self)
        sut.saved
            .bind(to: saved)
            .disposed(by: bag)
        scheduler.createColdObservable([
            .next(10, saveModel190815),
            .next(20, saveModel190822)
        ])
        .bind(to: sut.save)
        .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(saved.events.count, 2)
    }

    func testClose_FromSave() {
        let close = scheduler.createObserver(Void.self)
        sut.close
            .bind(to: close)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, saveModel190815)])
            .bind(to: sut.save)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(close.events.count, 1)
    }

    func testClose_FromCancel() {
        let close = scheduler.createObserver(Void.self)
        sut.close
            .bind(to: close)
            .disposed(by: bag)
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: sut.cancel)
            .disposed(by: bag)
        scheduler.start()
        XCTAssertEqual(close.events.count, 1)
    }
}

extension VocabularyDetailViewModelTests {

    private func setupRealm() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "RealmServiceTests"
    }

    private func initStub() {
        var models = [VocabularyRealm]()
        for index in 1...10 {
            let model = VocabularyRealm()
            model.id = "\(index)"
            model.episode = "Episode 190815"
            model.word = "Hello \(index)"
            model.note = "World \(index)"
            model.updateDate = Date()
            models.append(model)
        }
        _ = realmService.add(objects: models)
    }

    private func setupModels() {
        realmModel190815.id = "realmModel190815"
        realmModel190815.episode = "Episode 190815"
        realmModel190815.word = "Apple"
        realmModel190815.note = "蘋果🍎"
        realmModel190815.updateDate = Date()

        realmModel190822.id = "realmModel190815"
        realmModel190822.episode = "Episode 190822"
        realmModel190822.word = "Phone"
        realmModel190822.note = "手機📱"
        realmModel190822.updateDate = Date()

        let word190815 = "Apple"
        let note190815 = "蘋果🍎"
        saveModel190815 = VocabularySaveModel(word: word190815, note: note190815)

        let word190822 = "Phone"
        let note190822 = "電話📱"
        saveModel190822 = VocabularySaveModel(word: word190822, note: note190822)
    }

    private func flushData() {
        _ = realmService.deleteAll()
    }
}
