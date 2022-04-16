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
        let word = "Apple"
        let note = "蘋果🍎"
        let sut = VocabularySaveModel(word: word, note: note)
        XCTAssertEqual(sut.word, word)
        XCTAssertEqual(sut.note, note)
    }

    func testInit_WithNil() {
        let sut = VocabularySaveModel(word: nil, note: nil)
        XCTAssertNil(sut.word)
        XCTAssertNil(sut.note)
    }
}
