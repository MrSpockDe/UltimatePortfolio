//
//  TagTests.swift
//  UltimatePortfolioTests
//
//  Created by Albert on 12.11.23.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

final class TagTests: BaseTestCase {
    func testCreatingTagsAndIssues() {
        let targetCount = 10

        for _ in 0..<targetCount {
            let tag = Tag(context: managedObjectContext)

            for _ in 0..<targetCount {
                let issue = Issue(context: managedObjectContext)

                tag.addToIssues(issue)
            }
        }

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), targetCount,
                       "There should be \(targetCount) Tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), targetCount * targetCount,
                       "There should be \(targetCount * targetCount) Issues.")
    }

    func testDeletingTagsDoesNotDeleteIssues() throws {
        // create 5 tags with 10 issues each
        dataController.createSampleData()

        let request = Tag.fetchRequest()
        let tags = try managedObjectContext.fetch(request)

        // assert that the corresponding issues have not been deleted (nullify rule)
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5,
                       "There should be 5 tags prior deletion")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 5 * 10,
                       "There should be 50 issues prior deletion")

        // delete one of those tags
        managedObjectContext.delete(tags[0])

        // assert that the corresponding issues have not been deleted (nullify rule)
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 4,
                       "There should be 5 tags aftert Core deletion")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 5 * 10,
                       "There should be 50 issues after deletion of a tag.")
    }
}
