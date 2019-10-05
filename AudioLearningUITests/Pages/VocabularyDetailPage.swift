//
//  VocabularyDetailPage.swift
//  AudioLearningUITests
//
//  Created by Han Chen on 2019/10/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import XCTest

class VocabularyDetailPage: Page {
    lazy var wordTextField = app.textFields["Word"].firstMatch
    lazy var noteTextView = app.textViews["Note"].firstMatch
    lazy var saveButton = app.buttons["Save"].firstMatch
    lazy var cancelButton = app.buttons["Cancel"].firstMatch
    
    required init(_ app: XCUIApplication) {
        super.init(app)
    }
    
    func inputWord(_ text: String) -> Self {
        wordTextField.tap()
        wordTextField.typeText(text)
        return self
    }
    
    func inputNote(_ text: String) -> Self {
        noteTextView.tap()
        noteTextView.typeText(text)
        return self
    }
    
    func save() -> Self {
        saveButton.tap()
        return self
    }
    
    func cancel() -> Self {
        cancelButton.tap()
        return self
    }
}
