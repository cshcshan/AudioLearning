//
//  Page.swift
//  AudioLearningUITests
//
//  Created by Han Chen on 2019/10/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit
import XCTest

class Page {

    enum UIStatus: String {
        case exists = "exists == true"
        case notExists = "exists == false"
        case selected = "selected == true"
        case notSelected = "selected == false"
        case isHittable = "isHittable == true"
        case notHittable = "isHittable == false"
    }

    var app: XCUIApplication!

    required init(_ app: XCUIApplication) {
        self.app = app
    }

    func on<T: Page>(page: T.Type) -> T {
        page.init(app)
    }

    func expect(element: XCUIElement, status: UIStatus, within timeout: TimeInterval = 20) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: status.rawValue), object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        if result == .timedOut {
            XCTFail(expectation.description)
        }
    }

    func wait(for seconds: Int) -> Self {
        sleep(UInt32(seconds))
        return self
    }
}
