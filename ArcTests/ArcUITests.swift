//
//  ArcUITests.swift
//  ArcUITests
//
//  Created by Ziyan Nadeem on 9/9/2026.
//

import XCTest

final class ArcUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.wait(for: .runningForeground, timeout: 5)
        )
    }

    @MainActor
    func testHomeTabCanBeOpened() throws {
        let app = XCUIApplication()
        app.launch()

        let homeTab = app.tabBars.buttons["Home"]

        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))

        homeTab.tap()

        XCTAssertTrue(homeTab.isSelected)
    }

    @MainActor
    func testFeedTabCanBeOpened() throws {
        let app = XCUIApplication()
        app.launch()

        let feedTab = app.tabBars.buttons["Feed"]

        XCTAssertTrue(feedTab.waitForExistence(timeout: 5))

        feedTab.tap()

        XCTAssertTrue(feedTab.isSelected)
    }

    @MainActor
    func testProfileTabCanBeOpened() throws {
        let app = XCUIApplication()
        app.launch()

        let profileTab = app.tabBars.buttons["Profile"]

        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))

        profileTab.tap()

        XCTAssertTrue(profileTab.isSelected)
    }
    
    @MainActor
    func testUsercanSearchandOpen() throws {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.images["play.rectangle.fill"]/*[[".buttons[\"Feed\"].images",".buttons",".images[\"slideshow\"]",".images[\"play.rectangle.fill\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["magnifyingglass"]/*[[".otherElements",".buttons[\"Search\"]",".buttons[\"magnifyingglass\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.textFields["Search"]/*[[".otherElements.textFields[\"Search\"]",".textFields",".textFields[\"Search\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.keys["B"]/*[[".otherElements.keys[\"B\"]",".keys[\"B\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.keys["l"]/*[[".otherElements.keys[\"l\"]",".keys[\"l\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.keys["e"]/*[[".otherElements.keys[\"e\"]",".keys[\"e\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.keys["a"]/*[[".otherElements.keys[\"a\"]",".keys[\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.keys["c"]/*[[".otherElements.keys[\"c\"]",".keys[\"c\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.keys["h"]/*[[".otherElements.keys[\"h\"]",".keys[\"h\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app.buttons.matching(identifier: "magnifyingglass").element(boundBy: 0).tap()
        app/*@START_MENU_TOKEN@*/.buttons["Sheet Grabber"]/*[[".otherElements.buttons[\"Sheet Grabber\"]",".buttons[\"Sheet Grabber\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app.buttons["Bleach the Movie: Memories of Nobody"].images.firstMatch.tap()
        XCTAssertTrue(
                app.staticTexts["Bleach the Movie: Memories of Nobody"].firstMatch.waitForExistence(timeout: 5),
                "Expected content detail view to appear after tapping search result"
            )
    }
}
