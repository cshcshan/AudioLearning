//
//  RealmServiceTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/20.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import RealmSwift
@testable import AudioLearning

class RealmServiceTests: XCTestCase {
    
    var sut: RealmService!

    override func setUp() {
        super.setUp()
        setupRealm()
        sut = RealmService.shared
        initStub()
    }

    override func tearDown() {
        flushData()
        sut = nil
        super.tearDown()
    }
    
    func testAddObjects() {
        var models = [EpisodeRealmModel]()
        for index in 21...30 {
            let model = EpisodeRealmModel()
            model.episode = String(index)
            model.title = "Hello \(index)"
            model.desc = "This is \(index) minutes english."
            model.date = "201903\(index)".toDate(dateFormat: "yyyyMMdd")
            model.imagePath = "https://www.cshan.com/image\(index).jpg"
            model.path = "/episode-201903\(index).mp3"
            models.append(model)
        }
        let objects = sut.add(objects: models)
        XCTAssertEqual(objects?.count, models.count)
        let episodeRealmModels: [EpisodeRealmModel] = sut.loadAll()
        XCTAssertEqual(episodeRealmModels.count, 20)
    }
    
    func testAddObject() {
        let model = EpisodeRealmModel()
        model.episode = "100"
        model.title = "Hello World"
        model.desc = "This is 100 minutes english."
        model.date = "20190314".toDate(dateFormat: "yyyyMMdd")
        model.imagePath = "https://www.cshan.com/image.jpg"
        model.path = "/episode-201900314.mp3"
        let object = sut.add(object: model)
        XCTAssertEqual(object?.episode, model.episode)
        XCTAssertEqual(object?.title, model.title)
        XCTAssertEqual(object?.desc, model.desc)
        XCTAssertEqual(object?.date, model.date)
        XCTAssertEqual(object?.imagePath, model.imagePath)
        XCTAssertEqual(object?.path, model.path)
        let episodeRealmModels: [EpisodeRealmModel] = sut.loadAll()
        XCTAssertEqual(episodeRealmModels.count, 11)
    }
    
    func testUpdate() {
        let updateExpectationt = expectation(description: "Updated")
        
        let predicate = NSPredicate(format: "episode CONTAINS[c] '2'")
        let result = sut.update(type: EpisodeRealmModel.self, predicate: predicate) { (data) in
            guard let data = data else { return }
            let objects = Array(data)
            for object in objects {
                object.title = "World \(object.episode ?? "")"
            }
            updateExpectationt.fulfill()
        }
        XCTAssertTrue(result)
        
        let objects: [EpisodeRealmModel] = sut.filter(by: predicate, sortedByAscending: ["episode": true])
        XCTAssertEqual(objects[0].title, "World 12")
        XCTAssertEqual(objects[1].title, "World 20")
        
        waitForExpectations(timeout: 1.0) { (error) in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }
    
    func testUpdate_DontChangeAnything() {
        let updateExpectationt = expectation(description: "Updated")
        
        let predicate = NSPredicate(format: "episode CONTAINS[c] '2'")
        let result = sut.update(type: EpisodeRealmModel.self, predicate: predicate) { (_) in
            updateExpectationt.fulfill()
        }
        XCTAssertTrue(result)
        
        let objects: [EpisodeRealmModel] = sut.filter(by: predicate, sortedByAscending: ["episode": true])
        XCTAssertEqual(objects[0].title, "Hello 12")
        XCTAssertEqual(objects[1].title, "Hello 20")
        
        waitForExpectations(timeout: 1.0) { (error) in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }
    
    func testDelete() {
        let predicate = NSPredicate(format: "episode CONTAINS[c] '2'")
        let result = sut.delete(type: EpisodeRealmModel.self, predicate: predicate)
        XCTAssertTrue(result)
        let episodeRealmModels: [EpisodeRealmModel] = sut.loadAll()
        XCTAssertEqual(episodeRealmModels.count, 8)
    }
    
    func testDeleteAll() {
        let result = sut.deleteAll(type: EpisodeRealmModel.self)
        XCTAssertTrue(result)
        let episodeRealmModels: [EpisodeRealmModel] = sut.loadAll()
        XCTAssertEqual(episodeRealmModels.count, 0)
    }
    
    func testLoadAll() {
        let results: [EpisodeRealmModel] = sut.loadAll()
        XCTAssertEqual(results.count, 10)
    }
    
    func testLoadAll_EpisodeDescended() {
        let results: [EpisodeRealmModel] = sut.loadAll(sortedByAsc: ["episode": false])
        XCTAssertEqual(results[0].episode, "20")
        XCTAssertEqual(results[9].episode, "11")
    }
    
    func testFilter() {
        let predicate = NSPredicate(format: "episode CONTAINS[c] '2'")
        let results: [EpisodeRealmModel] = sut.filter(by: predicate)
        XCTAssertEqual(results[0].episode, "12")
        XCTAssertEqual(results[1].episode, "20")
    }
    
    func testFilter_EpisodeDescended() {
        let predicate = NSPredicate(format: "episode CONTAINS[c] '2'")
        let results: [EpisodeRealmModel] = sut.filter(by: predicate, sortedByAscending: ["episode": false])
        XCTAssertEqual(results[0].episode, "20")
        XCTAssertEqual(results[1].episode, "12")
    }
}

extension RealmServiceTests {
    
    private func setupRealm() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "RealmServiceTests"
    }
    
    private func initStub() {
        var models = [EpisodeRealmModel]()
        for index in 11...20 {
            let model = EpisodeRealmModel()
            model.episode = String(index)
            model.title = "Hello \(index)"
            model.desc = "This is \(index) minutes english."
            model.date = "201903\(index)".toDate(dateFormat: "yyyyMMdd")
            model.imagePath = "https://www.cshan.com/image\(index).jpg"
            model.path = "/episode-201903\(index).mp3"
            models.append(model)
        }
        _ = sut.add(objects: models)
    }
    
    private func flushData() {
        _ = sut.deleteAll(type: EpisodeRealmModel.self)
    }
}
