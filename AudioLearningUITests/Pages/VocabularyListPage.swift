//
//  VocabularyListPage.swift
//  AudioLearningUITests
//
//  Created by Han Chen on 2019/10/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import XCTest

class VocabularyListPage: Page {
    lazy var navigationTitle = app.navigationBars["Vocabulary"].firstMatch
    lazy var backButton = app.navigationBars.buttons.element(boundBy: 0)
    lazy var addButton = app.navigationBars.buttons["Add"].firstMatch
    lazy var tableView = app.tables["TableView"].firstMatch
    
    required init(_ app: XCUIApplication) {
        super.init(app)
    }
    
    func back() -> Self {
        backButton.tap()
        return self
    }
    
    func addWord() -> VocabularyDetailPage {
        addButton.tap()
        return VocabularyDetailPage(app)
    }
    
    func deleteWord() -> VocabularyListPage {
        let cell = tableView.cells.element(boundBy: 0)
        cell.swipeLeft()
        cell.buttons["Delete"].tap()
        return self
    }
}
