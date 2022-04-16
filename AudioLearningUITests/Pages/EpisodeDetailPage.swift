//
//  EpisodeDetailPage.swift
//  AudioLearningUITests
//
//  Created by Han Chen on 2019/10/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import XCTest

class EpisodeDetailPage: Page {
    lazy var backButton = app.navigationBars.buttons.element(boundBy: 0)
    lazy var playerView = app.otherElements["PlayerView"].firstMatch

    required init(_ app: XCUIApplication) {
        super.init(app)
    }

    func getNavigationTitle(from text: String) -> XCUIElement {
        let navigationTitle = app.navigationBars[text].firstMatch
        expect(element: navigationTitle, status: .exists, within: 5)
        return navigationTitle
    }

    func swipeUpPlayView() -> Self {
        expect(element: playerView, status: .exists, within: 5)
        playerView.swipeUp()
        return self
    }

    func swipeDownPlayView() -> Self {
        expect(element: playerView, status: .exists, within: 5)
        playerView.swipeDown()
        return self
    }

    func back() -> Self {
        backButton.tap()
        return self
    }
}
