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

final class VocabularyDetailViewModelTests: XCTestCase {
    typealias EpisodeWord = VocabularyDetailViewModel.EpisodeWord

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

    func test_word_fromVocabulary() {
        let word = scheduler.createObserver(String?.self)
        sut.state.word.drive(word).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, realmModel190815),
                .next(20, realmModel190822)
            ])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(word.events.count, 3)
        XCTAssertEqual(word.events, [
            .next(0, nil),
            .next(10, "Apple"),
            .next(20, "Phone")
        ])
    }

    func test_word_fromReset() {
        let word = scheduler.createObserver(String?.self)
        sut.state.word.drive(word).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, ()),
                .next(20, ())
            ])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(word.events.count, 3)
        XCTAssertEqual(word.events, [
            .next(0, nil),
            .next(10, nil),
            .next(20, nil)
        ])
    }

    func test_word_fromAddEpisodeWord() {
        let word = scheduler.createObserver(String?.self)
        sut.state.word.drive(word).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, EpisodeWord(episodeID: nil, word: "Hello")),
                .next(20, EpisodeWord(episodeID: nil, word: "World"))
            ])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(word.events.count, 3)
        XCTAssertEqual(word.events, [
            .next(0, nil),
            .next(10, "Hello"),
            .next(20, "World")
        ])
    }

    func test_word_fromVocabulary_thenReset_thenAddEpisodeWord() {
        let word = scheduler.createObserver(String?.self)
        sut.state.word.drive(word).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, EpisodeWord(episodeID: nil, word: "Hello"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, nil),
            .next(10, "Apple"),
            .next(20, nil),
            .next(30, "Hello")
        ])
    }

    func test_word_fromReset_thenAddEpisodeWord_thenVocabulary() {
        let word = scheduler.createObserver(String?.self)
        sut.state.word.drive(word).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, EpisodeWord(episodeID: nil, word: "Hello"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, nil),
            .next(10, nil),
            .next(20, "Hello"),
            .next(30, "Apple")
        ])
    }

    func test_word_fromAddEpisodeWord_thenLoad_thenReset() {
        let word = scheduler.createObserver(String?.self)
        sut.state.word.drive(word).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, EpisodeWord(episodeID: nil, word: "Hello"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, nil),
            .next(10, "Hello"),
            .next(20, "Apple"),
            .next(30, nil)
        ])
    }

    func test_word_fromAddEpisodeWord_thenReset_thenVocabulary() {
        let word = scheduler.createObserver(String?.self)
        sut.state.word.drive(word).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, EpisodeWord(episodeID: nil, word: "Hello"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, nil),
            .next(10, "Hello"),
            .next(20, nil),
            .next(30, "Apple")
        ])
    }

    func test_word_fromReset_thenVocabulary_thenAddEpisodeWord() {
        let word = scheduler.createObserver(String?.self)
        sut.state.word.drive(word).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, EpisodeWord(episodeID: nil, word: "Hello"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, nil),
            .next(10, nil),
            .next(20, "Apple"),
            .next(30, "Hello")
        ])
    }

    func test_word_fromVocabulary_thenAddEpisodeWord_thenReset() {
        let word = scheduler.createObserver(String?.self)
        sut.state.word.drive(word).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, EpisodeWord(episodeID: nil, word: "Hello"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(word.events.count, 4)
        XCTAssertEqual(word.events, [
            .next(0, nil),
            .next(10, "Apple"),
            .next(20, "Hello"),
            .next(30, nil)
        ])
    }

    func test_note_fromVocabulary() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, realmModel190815),
                .next(20, realmModel190822)
            ])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 3)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, "蘋果🍎"),
            .next(20, "手機📱")
        ])
    }

    func test_note_fromReset() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, ()),
                .next(20, ())
            ])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 3)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, nil),
            .next(20, nil)
        ])
    }

    func test_note_fromAddEpisodeWord() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, EpisodeWord(episodeID: nil, word: "Hello 1")),
                .next(20, EpisodeWord(episodeID: nil, word: "Hello 2"))
            ])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 5)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, nil),
            .next(10, "World 1"),
            .next(20, nil),
            .next(20, "World 2")
        ])
    }

    func test_note_fromAddEpisodeWordNotFound() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, EpisodeWord(episodeID: nil, word: "Hello")),
                .next(20, EpisodeWord(episodeID: nil, word: "World"))
            ])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 3)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, nil),
            .next(20, nil)
        ])
    }

    func test_note_fromLoad_thenReset_thenAddEpisodeWord_thenAddEpisodeWordNotFound() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(30, EpisodeWord(episodeID: nil, word: "Hello 1")),
                .next(40, EpisodeWord(episodeID: nil, word: "Not Found"))
            ])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, "蘋果🍎"),
            .next(20, nil),
            .next(30, nil),
            .next(30, "World 1"),
            .next(40, nil)
        ])
    }

    func test_note_fromAdd_thenAddEpisodeWord_thenAddEpisodeWordNotFound_thenVocabulary() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(20, EpisodeWord(episodeID: nil, word: "Hello 1")),
                .next(30, EpisodeWord(episodeID: nil, word: "Not Found"))
            ])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(40, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, nil),
            .next(20, nil),
            .next(20, "World 1"),
            .next(30, nil),
            .next(40, "蘋果🍎")
        ])
    }

    func test_note_fromAddEpisodeWord_thenAddEpisodeWordNotFound_thenLoad_thenAdd() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, EpisodeWord(episodeID: nil, word: "Hello 1")),
                .next(20, EpisodeWord(episodeID: nil, word: "Not Found"))
            ])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(40, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, nil),
            .next(10, "World 1"),
            .next(20, nil),
            .next(30, "蘋果🍎"),
            .next(40, nil)
        ])
    }

    func test_note_fromAddEpisodeWordNotFound_thenLoad_thenReset_thenAddEpisodeWord() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, EpisodeWord(episodeID: nil, word: "Not Found"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(40, EpisodeWord(episodeID: nil, word: "Hello 1"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, nil),
            .next(20, "蘋果🍎"),
            .next(30, nil),
            .next(40, nil),
            .next(40, "World 1")
        ])
    }

    func test_note_fromAddEpisodeWordNotFound_thenAddEpisodeWord_thenReset_thenVocabulary() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, EpisodeWord(episodeID: nil, word: "Not Found")),
                .next(20, EpisodeWord(episodeID: nil, word: "Hello 1"))
            ])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(40, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .start()

        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, nil),
            .next(20, nil),
            .next(20, "World 1"),
            .next(30, nil),
            .next(40, "蘋果🍎")
        ])
    }

    func test_note_fromAddEpisodeWord_thenReset_thenVocabulary_thenAddEpisodeWordNotFound() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, EpisodeWord(episodeID: nil, word: "Hello 1"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(30, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(40, EpisodeWord(episodeID: nil, word: "Not Found"))])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, nil),
            .next(10, "World 1"),
            .next(20, nil),
            .next(30, "蘋果🍎"),
            .next(40, nil)
        ])
    }

    func test_note_fromReset_thenVocabulary_thenAddEpisodeWordNotFound_thenAddEpisodeWord() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(20, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(30, EpisodeWord(episodeID: nil, word: "Not Found")),
                .next(40, EpisodeWord(episodeID: nil, word: "Hello 1"))
            ])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, nil),
            .next(20, "蘋果🍎"),
            .next(30, nil),
            .next(40, nil),
            .next(40, "World 1")
        ])
    }

    func test_note_fromVocabulary_thenAddEpisodeWordNotFound_thenAddEpisodeWord_thenReset() {
        let note = scheduler.createObserver(String?.self)
        sut.state.note.drive(note).disposed(by: bag)

        scheduler
            .createColdObservable([.next(10, realmModel190815)])
            .bind(to: sut.state.vocabulary)
            .disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(20, EpisodeWord(episodeID: nil, word: "Not Found")),
                .next(30, EpisodeWord(episodeID: nil, word: "Hello 1"))
            ])
            .bind(to: sut.event.addEpisodeWord)
            .disposed(by: bag)

        scheduler
            .createColdObservable([.next(40, ())])
            .bind(to: sut.event.reset)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(note.events.count, 6)
        XCTAssertEqual(note.events, [
            .next(0, nil),
            .next(10, "蘋果🍎"),
            .next(20, nil),
            .next(30, nil),
            .next(30, "World 1"),
            .next(40, nil)
        ])
    }
}

// MARK: - Save and Close

extension VocabularyDetailViewModelTests {

    func test_saveSuccessfully() {
        let saveSuccessfully = scheduler.createObserver(Void.self)
        sut.event.saveSuccessfully
            .bind(to: saveSuccessfully)
            .disposed(by: bag)

        scheduler
            .createColdObservable([
                .next(10, saveModel190815),
                .next(20, saveModel190822)
            ])
            .bind(to: sut.event.save)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(saveSuccessfully.events.count, 2)
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
            model.episodeID = "Episode 190815"
            model.word = "Hello \(index)"
            model.note = "World \(index)"
            model.updateDate = Date()
            models.append(model)
        }
        _ = realmService.add(objects: models)
    }

    private func setupModels() {
        realmModel190815.id = "realmModel190815"
        realmModel190815.episodeID = "Episode 190815"
        realmModel190815.word = "Apple"
        realmModel190815.note = "蘋果🍎"
        realmModel190815.updateDate = Date()

        realmModel190822.id = "realmModel190815"
        realmModel190822.episodeID = "Episode 190822"
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
