//
//  EpisodeUITests.swift
//  AudioLearningUITests
//
//  Created by Han Chen on 2019/10/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest

class EpisodeUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        continueAfterFailure = false
        app.launchArguments.append("-UITesting")
        app.launch()
    }

    override func tearDown() {}

    func testNavigationTitle() {
        let navigationTitle = EpisodeListPage(app).navigationTitle
        XCTAssertTrue(navigationTitle.exists)
    }
}

// MARK: - EpisodeDetail

extension EpisodeUITests {

    func testOpenEpisodeDetail_NavigationTitle_Back() {
        let episodeListPage = EpisodeListPage(app)
        let episodeDetailPage = episodeListPage.openEpisodeDetail()
        let cellText = episodeListPage.episodeCell.staticTexts.firstMatch.label
        _ = episodeDetailPage.getNavigationTitle(from: cellText)

        let navigationTitle = episodeDetailPage
            .back()
            .on(page: EpisodeListPage.self).navigationTitle
        XCTAssertTrue(navigationTitle.exists)
    }

    // MARK: Player View

    func testOpenEpisodeDetail_PlayerViewUpAndDown() {
        let episodeDetail = EpisodeListPage(app).openEpisodeDetail()
        XCTAssertEqual(episodeDetail.playerView.frame.height, 76)

        var playerView = episodeDetail.swipeUpPlayView().playerView
        XCTAssertEqual(playerView.frame.height, 195.5)

        playerView = episodeDetail.swipeDownPlayView().playerView
        XCTAssertEqual(playerView.frame.height, 76)
    }

    func testOpenEpisodeDetail_PlayerViewDownAndUp() {
        let episodeDetail = EpisodeListPage(app).openEpisodeDetail()
        XCTAssertEqual(episodeDetail.playerView.frame.height, 76)

        var playerView = episodeDetail.swipeDownPlayView().playerView
        XCTAssertEqual(playerView.frame.height, 76)

        playerView = episodeDetail.swipeUpPlayView().playerView
        XCTAssertEqual(playerView.frame.height, 195.5)

        playerView = episodeDetail.swipeDownPlayView().playerView
        XCTAssertEqual(playerView.frame.height, 76)
    }
}

// MARK: - Vocabulary

extension EpisodeUITests {

    func testOpenVocabulary_NavigationTitle_Back() {
        let vocabularyListPage = EpisodeListPage(app).openVocabularyList()
        var navigationTitle = vocabularyListPage.navigationTitle
        XCTAssertTrue(navigationTitle.exists)

        navigationTitle = vocabularyListPage
            .back()
            .on(page: EpisodeListPage.self).navigationTitle
        XCTAssertTrue(navigationTitle.exists)
    }

    func testOpenVocabulary_AddAndDeleteWord() {
        addUIInterruptionMonitor(withDescription: "Alert", handler: { alert -> Bool in
            alert.buttons["OK"].tap()
            return true
        })

        let vocabularyListPage = EpisodeListPage(app).openVocabularyList()
        let cellsAmount = vocabularyListPage.tableView.cells.count
        _ = vocabularyListPage
            .addWord()
            .cancel()

            .on(page: VocabularyListPage.self)
            .addWord()
            .save()

            .on(page: VocabularyListPage.self)
            .addWord()
            .inputWord("UI Testing: Hello")
            .inputNote("UI Testing: World")
            .save()

            .on(page: VocabularyListPage.self)
            .deleteWord()
        XCTAssertEqual(cellsAmount, vocabularyListPage.tableView.cells.count)
    }
}
