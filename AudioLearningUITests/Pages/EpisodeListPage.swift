//
//  EpisodeListPage.swift
//  AudioLearningUITests
//
//  Created by Han Chen on 2019/10/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import XCTest

class EpisodeListPage: Page {
    lazy var navigationTitle = app.navigationBars["6 Minute English"].firstMatch
    lazy var vocabularyButton = app.buttons["VocabularyButton"].firstMatch
    lazy var episodeCell = app.cells["EpisodeCell_0"].firstMatch
    
    required init(_ app: XCUIApplication) {
        super.init(app)
    }
    
    func openEpisodeDetail() -> EpisodeDetailPage {
        expect(element: episodeCell, status: .exists, within: 5)
        episodeCell.tap()
        return EpisodeDetailPage(app)
    }
    
    func openVocabularyList() -> VocabularyListPage {
        expect(element: vocabularyButton, status: .exists, within: 5)
        vocabularyButton.tap()
        return VocabularyListPage(app)
    }
}
