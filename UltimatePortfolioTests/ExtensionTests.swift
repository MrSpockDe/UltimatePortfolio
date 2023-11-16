//
//  ExtensionTests.swift
//  UltimatePortfolioTests
//
//  Created by Albert on 16.11.23.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

final class ExtensionTests: BaseTestCase {
    func testIssueTitleUnwrap() {
        let issue = Issue(context: managedObjectContext)

        let newTitle = "This is the new title"
        issue.title = newTitle
        XCTAssertEqual(issue.issueTitle, newTitle, "The new issueTitle should be \(newTitle)")

        let newIssueTitle = "This is the new Issue title"
        issue.issueTitle = newIssueTitle
        XCTAssertEqual(issue.title, newIssueTitle, "The new title should be \(newIssueTitle)")
    }

    func testIssueContentUnwrap() {
        let issue = Issue(context: managedObjectContext)

        let newContent = "This is the new content"
        issue.content = newContent
        XCTAssertEqual(issue.issueContent, newContent, "The new issueTitle should be \(newContent)")

        let newIssueContent = "This is the new Issue content"
        issue.issueContent = newIssueContent
        XCTAssertEqual(issue.content, newIssueContent, "The new title should be \(newIssueContent)")
    }

    func testIssueCretaionDateUnwrap() {
        let issue = Issue(context: managedObjectContext)
        let testDate = Date.now
        issue.creationDate = testDate
        XCTAssertEqual(issue.issueCreationDate, testDate, "The creation date should be \(testDate)")
    }
}
