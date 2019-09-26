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
    // swiftlint:enable line_length
    
    var listElement: Element? {
        guard let document = try? SwiftSoup.parse(listHtmlString) else { return nil }
        guard let elements = try? document.getAllElements() else { return nil }
        return elements.first()
    }
    
    var detailDocument: Document? {
        guard let path = Bundle.main.path(forResource: "ep-190815", ofType: "html") else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let htmlString = try? String(contentsOf: url) else { return nil }
        guard let document = try? SwiftSoup.parse(htmlString) else { return nil }
        return document
    }
    
    override func setUp() {
        super.setUp()
        sut = ParseSixMinutesHelper()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: ParseHtmlToEpisodeModels
    
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
    
    // MARK: ParseHtmlToEpisodeDetailModels
    
    func testParseHtmlToEpisodeDetailModel() {
        guard let path = Bundle.main.path(forResource: "ep-190815", ofType: "html") else {
            XCTFail("Cannot find the ep-190815.html file.")
            return
        }
        let url = URL(fileURLWithPath: path)
        guard let htmlString = try? String(contentsOf: url) else {
            XCTFail("Cannt get the content of ep-190815.html")
            return
        }
        let model = sut.parseHtmlToEpisodeDetailModel(by: htmlString, urlString: path, episode: "Episode 190815")
        XCTAssertNotNil(model)
        XCTAssertNotNil(model!.episode)
        XCTAssertNotNil(model!.path)
        XCTAssertNotNil(model!.scriptHtml)
        XCTAssertNotNil(model!.audioLink)
    }
    
    func testParseHtmlToEpisodeDetailModel_WithNil() {
        let model = sut.parseHtmlToEpisodeDetailModel(by: "", urlString: "", episode: "")
        XCTAssertNotNil(model)
        XCTAssertNotNil(model!.episode)
        XCTAssertNotNil(model!.path)
        XCTAssertNil(model!.scriptHtml)
        XCTAssertNil(model!.audioLink)
    }
}

extension ParseSixMinutesHelperTests {
    
    // MARK: Get Value From Top Item
    
    func testGetEpisode_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting topItemElement.")
            return
        }
        let episode = sut.getEpisode(by: element)
        XCTAssertEqual("Episode 190822", episode)
    }
    
    func testGetTitle_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting topItemElement.")
            return
        }
        let title = sut.getTitle(by: element)
        XCTAssertEqual("Does your age affect your political views?", title)
    }
    
    func testGetDesc_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting topItemElement.")
            return
        }
        let desc = sut.getDesc(by: element)
        XCTAssertEqual("Age and political views", desc)
    }
    
    func testGetDate_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting topItemElement.")
            return
        }
        let date = sut.getDate(by: element)
        XCTAssertEqual("22 Aug 2019", date)
    }
    
    func testGetImagePath_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting topItemElement.")
            return
        }
        let imagePath = sut.getImagePath(by: element)
        XCTAssertEqual("http://ichef.bbci.co.uk/images/ic/976xn/p07jtrrn.jpg", imagePath)
    }
    
    func testGetPath_TopItem() {
        guard let element = topItemElement else {
            XCTFail("Get an error when getting topItemElement.")
            return
        }
        let path = sut.getPath(by: element)
        XCTAssertEqual("/learningenglish/english/features/6-minute-english/ep-190822", path)
    }
}

extension ParseSixMinutesHelperTests {
    
    // MARK: Get Value From List
    
    func testGetEpisode_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting listElement.")
            return
        }
        let episode = sut.getEpisode(by: element)
        XCTAssertEqual("Episode 190815", episode)
    }
    
    func testGetTitle_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting listElement.")
            return
        }
        let title = sut.getTitle(by: element)
        XCTAssertEqual("Cryptocurrencies", title)
    }
    
    func testGetDesc_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting listElement.")
            return
        }
        let desc = sut.getDesc(by: element)
        XCTAssertEqual("Libra, Bitcoin... would you invest in digital money?", desc)
    }
    
    func testGetDate_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting listElement.")
            return
        }
        let date = sut.getDate(by: element)
        XCTAssertEqual("15 Aug 2019", date)
    }
    
    func testGetImagePath_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting listElement.")
            return
        }
        let imagePath = sut.getImagePath(by: element)
        XCTAssertEqual("http://ichef.bbci.co.uk/images/ic/624xn/p07hjdrn.jpg", imagePath)
    }
    
    func testGetPath_FromList() {
        guard let element = listElement else {
            XCTFail("Get an error when getting listElement.")
            return
        }
        let path = sut.getPath(by: element)
        XCTAssertEqual("/learningenglish/english/features/6-minute-english/ep-190815", path)
    }
}

extension ParseSixMinutesHelperTests {
    
    // MARK: Get Value From Detail
    
    func testGetScriptHtml_FromDetail() {
        guard let document = detailDocument else {
            XCTFail("Get an error when getting detailDocument.")
            return
        }
        let scriptHtml = sut.getScriptHtml(by: document)
        
        // swiftlint:disable line_length
        let expecting = "<h3><strong>Introduction</strong></h3> \n<p>&nbsp;</p> \n<p>A new kind of money might be appearing soon - Libra from Facebook. Sam and Catherine discuss how different it is from Bitcoin, give you the basics about cryptocurrencies and teach you related vocabulary.</p> \n<h3><strong>This week\'s question</strong></h3> \n<p>Bitcoin was the first cryptocurrency, but when was it created? Was it:</p> \n<p>a) 2008</p> \n<p>b) 2009</p> \n<p>c) 2010</p> \n<p>The answer is at the end of the programme.</p> \n<h3><strong>Vocabulary</strong>&nbsp;</h3> \n<p><strong>cryptography<br></strong>the use of complex codes to keep computer systems and information secure&nbsp;</p> \n<p><strong>currency<br></strong>the money of a particular country<strong>&nbsp;</strong></p> \n<p><strong>cryptocurrency<br></strong>digitally produced money that is not controlled by banks or governments<strong>&nbsp;</strong></p> \n<p><strong>subject to the whims of<br></strong>being controlled by unpredictable decisions and trends<strong>&nbsp;</strong></p> \n<p><strong>notoriously volatile<br></strong>well known for changing by a large amount in an unpredictable way<strong>&nbsp;</strong></p> \n<p><strong>stable<br></strong>predictable and without big unexpected changes</p> \n<h3>Transcript&nbsp;</h3> \n<p><em>Note: This is not a word for word transcript</em>&nbsp;&nbsp;</p> \n<p><strong>Catherine<br></strong>Hello. This is 6 Minute English, I\'m Catherine.<strong>&nbsp;</strong></p> \n<p><strong>Sam<br></strong>And I\'m Sam.&nbsp;</p> \n<p><strong>Catherine<br></strong>Now, Sam, what can you tell us about <strong>cryptocurrencies</strong>?<strong>&nbsp;</strong></p> \n<p><strong>Sam<br></strong>The word is a combination of crypto, from <strong>cryptography</strong>, which is to do with using clever software codes to protect computer information and systems, and <strong>currency</strong>, which is the money of a particular country. So<strong> cryptocurrency</strong>, very simply, meanscode money. We usually think of money as notes and coins which come from a country’s bank. But a <strong>cryptocurrency</strong> doesn’t have physical money. It’s purely digital and is not controlled by banks or governments but by the people who have it and very complex computer codes. Perhaps the most well-known is Bitcoin.&nbsp;</p> \n<p><strong>Catherine<br></strong>Well, you seem to know a fair bit about <strong>cryptocurrency</strong> actually… anyway, now a new player is joining the digital money system as Facebook have announced they are launching their own digital <strong>currency</strong>. They are calling it \'Libra\'. And we’ll be finding a little bit more about this topic in the programme, but first, a question. Now, Sam, you mentioned Bitcoin as being a well-known <strong>cryptocurrency</strong>. It was, in fact, the first <strong>cryptocurrency</strong>, but when was Bitcoin created? Was it:</p> \n<p>a) 2008<br>b) 2009 or<br>c) 2010?<strong><br></strong></p> \n<p><strong>Sam<br> </strong>I’m going to say 2010.&nbsp;</p> \n<p><strong>Catherine<br> </strong>OK. Well, I\'ll reveal the answer later in the programme. Now, Jemima Kelly is a financial journalist. She was talking on the BBC radio programme Money Box Live about the plans for Libra. She says it\'s not really a <strong>cryptocurrency</strong> because it\'s actually backed up by a number of real <strong>currencies</strong>. So which <strong>currencies</strong> does she mention?&nbsp;</p> \n<p><strong>Jemima Kelly<br></strong>A <strong>cryptocurrency</strong> is normally <strong>subject to the whims of</strong> crypto markets, which are <strong>notoriously</strong> <strong>volatile</strong>, whereas Libra is kept <strong>stable</strong> by being backed up by a basket of currencies, in this case, the dollar, the pound, the euro and the Swiss franc.</p> \n<p><strong>Catherine<br></strong>So which currencies did she say were backing up Libra, Sam?&nbsp;</p> \n<p><strong>Sam<br></strong>She said that the dollar, the pound, the euro and Swiss franc were the currencies that would be backing up Libra.&nbsp;</p> \n<p><strong>Catherine<br></strong>And this is different from regular <strong>cryptocurrencies</strong>, isn’t it?&nbsp;</p> \n<p><strong>Sam<br></strong>Yes, <strong>cryptocurrencies</strong> are completely independent of financial institutions and other <strong>currencies</strong>.&nbsp;</p> \n<p><strong>Catherine<br></strong>And this can make them risky, can’t it?&nbsp;</p> \n<p><strong>Sam<br></strong>Yes, she says that <strong>cryptocurrency </strong>markets are <strong>notoriously volatile</strong>. Something that is <strong>volatile</strong> can change very quickly. When it comes to <strong>currency</strong>, it means that its value can go up or down by a large amount over a very short period of time.&nbsp;</p> \n<p><strong>Catherine<br></strong>And it’s described as <strong>notoriously </strong>volatile because this has actually happened a few times in the past. Something that is <strong>notorious</strong> is well known or famous but for a negative reason. So the value of a currency going up and down in a volatile way – that\'s not positive.&nbsp;</p> \n<p><strong>Sam<br></strong>If you want to take the risk you could make a lot of money, but you could also lose a lot of money - more than you invested.&nbsp;</p> \n<p><strong>Catherine<br></strong>So why are cryptocurrencies so <strong>volatile</strong>?&nbsp;</p> \n<p><strong>Sam<br> </strong>Most <strong>currencies </strong>are reasonably <strong>stable</strong>. This is the opposite of<strong> volatile</strong>. They don’t change a lot over a short period of time. There can be big changes but usually governments and banks control <strong>currencies</strong> to prevent it. <strong>Cryptocurrencies </strong>don’t have those controls. What Jemima Kelly said was that they are <strong>subject to the whims</strong> <strong>of </strong>the crypto markets. A <strong>whim </strong>is an unpredictable or irrational decision or trend and if you are <strong>subject to the whims</strong> of something, or someone, it means that metaphorically you are a passenger in a self-driving car which may decide just to drive off the edge of a cliff. So it might be an exciting ride, but it could end in disaster.&nbsp;</p> \n<p><strong>Catherine<br></strong>Right, it’s time now to get the answer to the question I asked at the beginning of the programme. Bitcoin was the first cryptocurrency, but when was it created? Was it:</p> \n<p>a) 2008<br>b) 2009<br>c) 2010?<strong><br></strong></p> \n<p><strong>Sam<br></strong>I said 2010, but I’m not really sure.&nbsp;</p> \n<p><strong>Catherine<br> </strong>And you\'re absolutely wrong! The correct answer is 2009, so no luck for you this time, but congratulations to everyone who did get that right. Well, anyway, let’s round off today with a review of today’s vocabulary.</p> \n<p><strong>Sam<br></strong>First off there is <strong>cryptography </strong>which is the use of special codes to keep computer systems and content safe.&nbsp;</p> \n<p><strong>Catherine<br></strong>A <strong>currency</strong> is the money of a particular country, for example in the UK we have the pound, in the US there’s the dollar and in many countries in Europe the <strong>currency</strong> is the euro.&nbsp;</p> \n<p><strong>Sam<br></strong><strong>Cryptocurrency </strong>is a combination of <strong>cryptography</strong> and <strong>currency </strong>and it’s used for a finance system that is based on secure digital coins that are not connected to banks or governments.&nbsp;</p> \n<p><strong>Catherine<br></strong>We then had the expression <strong>subject to the whims of</strong>. <strong>Whims</strong> are unpredictable decisions and if you are <strong>subject to them</strong> it means you can’t control them, you have no choice but to go in the direction those <strong>whims</strong> lead.&nbsp;</p> \n<p><strong>Sam<br> </strong>This means that the value of cryptocurrencies are <strong>notoriously volatile</strong>. They have a history of going up or down in value by large amounts and very quickly. And that’s not good.&nbsp;</p> \n<p><strong>Catherine<br> </strong>Well, it might be good if it goes up!</p> \n<p><strong>Sam</strong><br>True.</p> \n<p><strong>Catherine</strong><br>But if you want less risk, if you want your currency to be the opposite of <strong>volatile</strong>, if you want it, in other words, to be <strong>stable</strong>, then maybe <strong>cryptocurrencies</strong> are not for you.&nbsp;</p> \n<p><strong>Sam<br></strong>Well, we are <strong>subject to the whims</strong> of the schedule which means our 6 minutes are up. We look forward to your company again soon. Bye for now.&nbsp;</p> \n<p><strong>Catherine</strong><strong> <br></strong>Bye!</p>"
        // swiftlint:enable line_length
        
        XCTAssertEqual(expecting, scriptHtml)
    }
    
    func testGetAudioLink_FromDetail() {
        guard let document = detailDocument else {
            XCTFail("Get an error when getting detailDocument.")
            return
        }
        let audioLink = sut.getAudioLink(by: document)
        XCTAssertEqual("http://downloads.bbc.co.uk/learningenglish/features/6min/190815_6min_english_cryptocurrency_download.mp3", audioLink)
    }
}
