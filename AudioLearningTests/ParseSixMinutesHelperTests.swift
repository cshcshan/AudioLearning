//
//  ParseSixMinutesHelperTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import SwiftSoup
@testable import AudioLearning

class ParseSixMinutesHelperTests: XCTestCase {
    
    var sut: ParseSixMinutesHelper!
    
    // swiftlint:disable line_length
    let topItemHtmlString = """
        <div class="widget widget-bbcle-coursecontentlist widget-bbcle-coursecontentlist-featured widget-progress-enabled" data-widget-index="4">
            <div data-feature-item="/features/6-minute-english/ep-190822" class="progress-enabled completed hide" style="display: block;"><span data-i18n-message-id="completed" class="not-translated _bbcle_translate_wrapper" lang="en">completed</span></div>
                <div class="img">
                    <a href="/learningenglish/english/features/6-minute-english/ep-190822"><img src="http://ichef.bbci.co.uk/images/ic/976xn/p07jtrrn.jpg" id="1_p07jtrrn" data-type="image" data-pid="p07jtrrn" data-title="" data-description="" srcset="http://ichef.bbci.co.uk/images/ic/976xn/p07jtrrn.jpg 976w,http://ichef.bbci.co.uk/images/ic/1920xn/p07jtrrn.jpg 1952w" width="976" alt=""></a>
            </div>
            <div class="text">
                <h2><a href="/learningenglish/english/features/6-minute-english/ep-190822">Does your age affect your political views?</a></h2>
                <div class="details">
                    <h3><b>Episode 190822 </b>/ 22 Aug 2019</h3>
                    <p>Age and political views</p>
                </div>
            </div>
        </div>
        """
    var topItemElement: Element? {
        guard let document = try? SwiftSoup.parse(topItemHtmlString) else { return nil }
        guard let elements = try? document.getAllElements() else { return nil }
        return elements.first()
    }
    
    let listHtmlString = """
         <li class="course-content-item active">
            <div data-feature-item="/features/6-minute-english/ep-190815" class="progress-enabled completed hide">
                <span  data-i18n-message-id="completed" class="not-translated _bbcle_translate_wrapper" lang="en">completed</span>
            </div>
            <div class="img">
                <a href="/learningenglish/english/features/6-minute-english/ep-190815"><img src="http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg" id="1_p07hjdrn" data-type="image" data-pid="p07hjdrn" data-title="" data-description="" srcset="http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg 624w,http://ichef.bbci.co.uk/images/ic/1248xn/p07hjdrn.jpg 1248w" width="624" alt="" /></a>
            </div>
            <div class="text">
                <h2><a href="/learningenglish/english/features/6-minute-english/ep-190815">Cryptocurrencies</a></h2>
                <div class="details">
                    <h3><b>Episode 190815 </b>/ 15 Aug 2019 </h3>
                    <p>Libra, Bitcoin... would you invest in digital money?</p>
                </div>
            </div>
         </li>
        """
    
    var listElement: Element? {
        guard let document = try? SwiftSoup.parse(listHtmlString) else { return nil }
        guard let elements = try? document.getAllElements() else { return nil }
        return elements.first()
    }
    // swiftlint:enable line_length
    
    override func setUp() {
        super.setUp()
        sut = ParseSixMinutesHelper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testParseHtmlToEpisodeModels() {
        guard let path = Bundle.main.path(forResource: "6-minute-english", ofType: "html") else {
            XCTFail("Cannot find the 6-minute-english.html file.")
            return
        }
        let url = URL(fileURLWithPath: path)
        guard let htmlString = try? String(contentsOf: url) else {
            XCTFail("Cannt get the content of 6-minute-english.html")
            return
        }
        let array = sut.parseHtmlToEpisodeModels(by: htmlString, urlString: path)
        XCTAssertEqual(array.count, 20 + 1)
    }
    
    func testParseHtmlToEpisodeModels_WithNil() {
        let array = sut.parseHtmlToEpisodeModels(by: "", urlString: "")
        XCTAssertTrue(array.count == 0)
    }
}

extension ParseSixMinutesHelperTests {
    
    // MARK: Get Value From Top Item
    
    func testGetEpisode_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let episode = sut.getEpisode(by: element)
        XCTAssertEqual("Episode 190822", episode)
    }
    
    func testGetTitle_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let title = sut.getTitle(by: element)
        XCTAssertEqual("Does your age affect your political views?", title)
    }
    
    func testGetDesc_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let desc = sut.getDesc(by: element)
        XCTAssertEqual("Age and political views", desc)
    }
    
    func testGetDate_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let date = sut.getDate(by: element)
        XCTAssertEqual("22 Aug 2019", date)
    }
    
    func testGetImagePath_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let imagePath = sut.getImagePath(by: element)
        XCTAssertEqual("http://ichef.bbci.co.uk/images/ic/976xn/p07jtrrn.jpg", imagePath)
    }
    
    func testGetLink_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let link = sut.getLink(by: element)
        XCTAssertEqual("/learningenglish/english/features/6-minute-english/ep-190822", link)
    }
}

extension ParseSixMinutesHelperTests {
    
    // MARK: Get Value From List
    
    func testGetEpisode_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let episode = sut.getEpisode(by: element)
        XCTAssertEqual("Episode 190815", episode)
    }
    
    func testGetTitle_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let title = sut.getTitle(by: element)
        XCTAssertEqual("Cryptocurrencies", title)
    }
    
    func testGetDesc_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let desc = sut.getDesc(by: element)
        XCTAssertEqual("Libra, Bitcoin... would you invest in digital money?", desc)
    }
    
    func testGetDate_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let date = sut.getDate(by: element)
        XCTAssertEqual("15 Aug 2019", date)
    }
    
    func testGetImagePath_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let imagePath = sut.getImagePath(by: element)
        XCTAssertEqual("http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg", imagePath)
    }
    
    func testGetLink_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting liElement.")
            return
        }
        let link = sut.getLink(by: element)
        XCTAssertEqual("/learningenglish/english/features/6-minute-english/ep-190815", link)
    }
}
