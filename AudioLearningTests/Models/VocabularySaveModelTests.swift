//
//  VocabularySaveModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/24.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
@testable import AudioLearning

class VocabularySaveModelTests: XCTestCase {
    
    func testInit() {
        let episode = "New Episode"
        let word = "Apple"
        let note = "蘋果🍎"
        let sut = VocabularySaveModel(episode: episode, word: word, note: note)
        XCTAssertEqual(sut.episode, episode)
        XCTAssertEqual(sut.word, word)
        XCTAssertEqual(sut.note, note)
    }
    
    func testInit_WithNil() {
        let sut = VocabularySaveModel(episode: nil, word: nil, note: nil)
        XCTAssertNil(sut.episode)
        XCTAssertNil(sut.word)
        XCTAssertNil(sut.note)
    }
}
