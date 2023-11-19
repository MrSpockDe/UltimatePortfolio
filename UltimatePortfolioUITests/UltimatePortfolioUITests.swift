//
//  UltimatePortfolioUITests.swift
//  UltimatePortfolioUITests
//
//  Created by Albert on 19.11.23.
//

import XCTest

extension XCUIElement {
    func clear() {
        guard let stringValue = self.value as? String else {
            XCTFail("Failed to clear textfiled.")
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}

final class UltimatePortfolioUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    func testAppStartsWithNavigationBar() throws {
        XCTAssertTrue(app.navigationBars.element.exists, "Tere should be a navigationBar when the app launches.")
    }

    func testAppHasBasicButtonsOnLaunch() throws {
        // It is important to launch the app on a simulator that
        // is configured in english language, because the first
        // button "Filters" is the NavTitle of the Filter Side Bar
        // hich is "Filter" in German
        XCTAssertTrue(app.navigationBars.buttons["Filters"].exists,
                      "On Start on the App the Filters-Button shall exist.")
        XCTAssertTrue(app.navigationBars.buttons["Filter"].exists,
                      "On Start on the App the Filter-Button shall exist.")
        XCTAssertTrue(app.navigationBars.buttons["New Issue"].exists,
                      "On Start on the App the New Issue-Button shall exist.")
    }

    func testNoIssuesAtStart() {
        XCTAssertEqual(app.cells.count, 0, " There should be no lis rows (Issues) at Launch.")
    }

    func testCreateAndDeletingIssues() {
        for tapCount in 1...5 {
            app.navigationBars["Issues"].buttons["New Issue"].tap()
            app.buttons["Issues"].tap()

            XCTAssertEqual(app.cells.count, tapCount,
                           "\(tapCount) issues should habe been added and should be visible on screen.")
        }

        for tapCount in (0...4).reversed() {
            app.cells.firstMatch.swipeLeft()
            app.buttons["Delete"].tap()

            XCTAssertEqual(app.cells.count, tapCount,
                           "There should be \(tapCount) list rows after deleting.")
        }
    }

    func testEditingIssueTitleUpdatesCorrectly() {
        let myNewIssueTitle = "My New Issue Title"
        XCTAssertEqual(app.cells.count, 0, "There should be no list rows at start.")

        app.buttons["New Issue"].tap()
        app.buttons["Issues"].tap()
        app.cells.firstMatch.tap()

        // now editing
        app.textFields["Enter the issue title here"].tap()
        app.textFields["Enter the issue title here"].clear()
        app.typeText(myNewIssueTitle)

        // go back to previous screen
        app.buttons["Issues"].tap()
        // for UITest the new cell is tappable and therefore a button now
        XCTAssertTrue(app.buttons[myNewIssueTitle].exists,
                      "A cell with title '\(myNewIssueTitle)' should exist.")
    }

    func testEditingIssuePriorityShowsIcon() {
        app.buttons["New Issue"].tap()
        app.buttons["Medium"].tap()
        app.buttons["High"].tap()

        // go back to previous screen
        app.buttons["Issues"].tap()
        // for assesibilty the icon uses an identifier
        // title + High Priority
        XCTAssertTrue(app.images["New Issue High Priority"].exists, "The high priority icon should be shown")
    }

    func testAllAwardsShowLockedAllert() {
        app.buttons["Filters"].tap()
        app.buttons["Show awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "The Locked alert should be shown")
            app.buttons["OK"].tap()
        }
    }
}
