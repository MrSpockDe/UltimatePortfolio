//
//  DevelopmentTests.swift
//  UltimatePortfolioTests
//
//  Created by Albert on 16.11.23.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

final class DevelopmentTests: BaseTestCase {
    func testSampleDataCreationWorks() {
        // When
        dataController.createSampleData()

        // Then
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "Sampledata should contain 5 Tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "Sampledata should contain 10 Issues.")
    }

    func testDeleteAllFunction() {
        // When
        dataController.createSampleData()
        dataController.deleteAll()

        // Then
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "Sampledata should contain 0 Tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 0, "Sampledata should contain 0 Issues.")
    }

    func testRandomDataCreationTags() {
        var randomCount: Int

        // When
        for _ in 1...100 {
            randomCount = Int.random(in: 0...1000)
            for _ in 0..<randomCount {
                let tag = Tag(context: managedObjectContext)
                tag.name = UUID().uuidString
                tag.id = UUID()
            }
            dataController.save()
            // print(randomCount)
            // Then
            XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), randomCount,
                           "There should be \(randomCount) Tags")
            dataController.deleteAll()
        }
    }

    func testRandomDataCreationIssues() {
        var randomCount: Int

        // When
        for _ in 1...100 {
            randomCount = Int.random(in: 0...1000)
            for _ in 0..<randomCount {
                let issue = Issue(context: managedObjectContext)
                issue.title = UUID().uuidString
            }
            dataController.save()
            // print(randomCount)
            // Then
            XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), randomCount,
                           "There should be \(randomCount) Issues")
            dataController.deleteAll()
        }
    }

    func testExampleTagsHaveNoIssues() {
        // When
        let tag = Tag.example

        // Then
        XCTAssertEqual(tag.issues?.count, 0, "example tag should have no issues.")
    }

    func testExampleIssueIsHighPriority() {
        // When
        let issue = Issue.example

        // Then
        XCTAssertEqual(issue.priority, 2, "Example issue shall have high priority.")
    }
}
