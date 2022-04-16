//
//  RealmServiceTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/20.
//  Copyright © 2019 cshan. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import AudioLearning

class RealmServiceTests: XCTestCase {

    var sut: RealmService<EpisodeRealm>!
    var scheduler: TestScheduler!
    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        setupRealm()
        sut = RealmService()
        initStub()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        flushData()
        sut = nil
        super.tearDown()
    }

    func testAddObjects() {
        let objects = scheduler.createObserver([EpisodeRealm]?.self)
        var models = [EpisodeRealm]()
        for index in 21...30 {
            let model = EpisodeRealm()
            model.id = String(index)
            model.title = "Hello \(index)"
            model.desc = "This is \(index) minutes english."
            model.date = "201903\(index)".date(withDateFormat: "yyyyMMdd")
            model.imagePath = "https://www.cshan.com/image\(index).jpg"
            model.path = "/episode-201903\(index).mp3"
            models.append(model)
        }
        sut.add(objects: models)
            .bind(to: objects)
            .disposed(by: bag)
        XCTAssertEqual(objects.events, [.next(0, models), .completed(0)])
    }

    func testAddObject() {
        let object = scheduler.createObserver(EpisodeRealm?.self)
        let model = EpisodeRealm()
        model.id = "100"
        model.title = "Hello World"
        model.desc = "This is 100 minutes english."
        model.date = "20190314".date(withDateFormat: "yyyyMMdd")
        model.imagePath = "https://www.cshan.com/image.jpg"
        model.path = "/episode-201900314.mp3"
        sut.add(object: model)
            .bind(to: object)
            .disposed(by: bag)
        XCTAssertEqual(object.events, [.next(0, model), .completed(0)])
    }

    func testUpdate() {
        let success = scheduler.createObserver(Bool.self)

        let updateExpectation = expectation(description: "Updated")
        let predicate = NSPredicate(format: "id CONTAINS[c] '2'")
        sut.update(predicate: predicate, updateHandler: { data in
            guard let data = data else { return }
            let objects = Array(data)
            for object in objects {
                object.title = "World \(object.id ?? "")"
            }
            updateExpectation.fulfill()
        })
        .bind(to: success)
        .disposed(by: bag)
        XCTAssertEqual(success.events, [.next(0, true), .completed(0)])

        let filterExpectation = expectation(description: "Filter")
        sut.filterObjects
            .subscribe(onNext: { episodeRealms in
                filterExpectation.fulfill()
                XCTAssertEqual(episodeRealms[0].title, "World 12")
                XCTAssertEqual(episodeRealms[1].title, "World 20")
            })
            .disposed(by: bag)
        sut.filter.onNext((predicate, ["id": true]))
        waitForExpectations(timeout: 1.0) { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }

    func testUpdate_DontChangeAnything() {
        let success = scheduler.createObserver(Bool.self)

        let updateExpectationt = expectation(description: "Updated")
        let predicate = NSPredicate(format: "id CONTAINS[c] '2'")
        sut.update(predicate: predicate, updateHandler: { _ in
            updateExpectationt.fulfill()
        })
        .bind(to: success)
        .disposed(by: bag)
        XCTAssertEqual(success.events, [.next(0, true), .completed(0)])

        let filterExpectation = expectation(description: "Filter")
        sut.filterObjects
            .subscribe(onNext: { episodeRealms in
                filterExpectation.fulfill()
                XCTAssertEqual(episodeRealms[0].title, "Hello 12")
                XCTAssertEqual(episodeRealms[1].title, "Hello 20")
            })
            .disposed(by: bag)
        sut.filter.onNext((predicate, ["id": true]))
        waitForExpectations(timeout: 1.0) { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }

    func testDelete() {
        let success = scheduler.createObserver(Bool.self)
        let predicate = NSPredicate(format: "id CONTAINS[c] '2'")
        sut.delete(predicate: predicate)
            .bind(to: success)
            .disposed(by: bag)
        XCTAssertEqual(success.events, [.next(0, true), .completed(0)])

        let loadAllExpectation = expectation(description: "Load All")
        sut.allObjects
            .subscribe(onNext: { episodeRealms in
                loadAllExpectation.fulfill()
                XCTAssertEqual(episodeRealms.count, 8)
            })
            .disposed(by: bag)
        sut.loadAll.onNext(nil)
        waitForExpectations(timeout: 1.0) { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }

    func testDeleteAll() {
        let success = scheduler.createObserver(Bool.self)
        sut.deleteAll()
            .bind(to: success)
            .disposed(by: bag)
        XCTAssertEqual(success.events, [.next(0, true), .completed(0)])

        let loadAllExpectation = expectation(description: "Load All")
        sut.allObjects
            .subscribe(onNext: { episodeRealms in
                loadAllExpectation.fulfill()
                XCTAssertEqual(episodeRealms.count, 0)
            })
            .disposed(by: bag)
        sut.loadAll.onNext(nil)
        waitForExpectations(timeout: 1.0) { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }

    func testLoadAll() {
        let loadAllExpectation = expectation(description: "Load All")
        sut.allObjects
            .subscribe(onNext: { episodeRealms in
                loadAllExpectation.fulfill()
                XCTAssertEqual(episodeRealms.count, 10)
            })
            .disposed(by: bag)
        sut.loadAll.onNext(nil)
        waitForExpectations(timeout: 1.0) { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }

    func testLoadAll_EpisodeDescended() {
        let loadAllExpectation = expectation(description: "Load All")
        sut.allObjects
            .subscribe(onNext: { episodeRealms in
                loadAllExpectation.fulfill()
                XCTAssertEqual(episodeRealms[0].id, "20")
                XCTAssertEqual(episodeRealms[9].id, "11")
            })
            .disposed(by: bag)
        sut.loadAll.onNext(["id": false])
        waitForExpectations(timeout: 1.0) { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }

    func testFilter() {
        let filterExpectation = expectation(description: "Filter")
        let predicate = NSPredicate(format: "id CONTAINS[c] '2'")
        sut.filterObjects
            .subscribe(onNext: { episodeRealms in
                filterExpectation.fulfill()
                XCTAssertEqual(episodeRealms[0].id, "12")
                XCTAssertEqual(episodeRealms[1].id, "20")
            })
            .disposed(by: bag)
        sut.filter.onNext((predicate, nil))
        waitForExpectations(timeout: 1.0) { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }

    func testFilter_EpisodeDescended() {
        let filterExpectation = expectation(description: "Filter")
        let predicate = NSPredicate(format: "id CONTAINS[c] '2'")
        sut.filterObjects
            .subscribe(onNext: { episodeRealms in
                filterExpectation.fulfill()
                XCTAssertEqual(episodeRealms[0].id, "20")
                XCTAssertEqual(episodeRealms[1].id, "12")
            })
            .disposed(by: bag)
        sut.filter.onNext((predicate, ["id": false]))
        waitForExpectations(timeout: 1.0) { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }
}

extension RealmServiceTests {

    private func setupRealm() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "RealmServiceTests"
    }

    private func initStub() {
        var models = [EpisodeRealm]()
        for index in 11...20 {
            let model = EpisodeRealm()
            model.id = String(index)
            model.title = "Hello \(index)"
            model.desc = "This is \(index) minutes english."
            model.date = "201903\(index)".date(withDateFormat: "yyyyMMdd")
            model.imagePath = "https://www.cshan.com/image\(index).jpg"
            model.path = "/episode-201903\(index).mp3"
            models.append(model)
        }
        _ = sut.add(objects: models)
    }

    private func flushData() {
        _ = sut.deleteAll()
    }
}
