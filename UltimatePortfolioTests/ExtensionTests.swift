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
    // Test Issues Extension
    func testIssueTitleUnwrap() {
        // Given
        let issue = Issue(context: managedObjectContext)

        // When
        let newTitle = "This is the new title"
        issue.title = newTitle

        // Then
        XCTAssertEqual(issue.issueTitle, newTitle, "The new issueTitle should be \(newTitle)")

        // When
        let newIssueTitle = "This is the new Issue title"
        issue.issueTitle = newIssueTitle

        // Then
        XCTAssertEqual(issue.title, newIssueTitle, "The new title should be \(newIssueTitle)")
    }

    func testIssueContentUnwrap() {
        // Given
        let issue = Issue(context: managedObjectContext)

        // When
        let newContent = "This is the new content"
        issue.content = newContent

        // Then
        XCTAssertEqual(issue.issueContent, newContent, "The new issueTitle should be \(newContent)")

        // When
        let newIssueContent = "This is the new Issue content"
        issue.issueContent = newIssueContent

        // Then
        XCTAssertEqual(issue.content, newIssueContent, "The new title should be \(newIssueContent)")
    }

    func testIssueCretaionDateUnwrap() {
        // Given
        let issue = Issue(context: managedObjectContext)
        let testDate = Date.now

        // When
        issue.creationDate = testDate

        // Then
        XCTAssertEqual(issue.issueCreationDate, testDate, "The creation date should be \(testDate)")
    }

    func testIssueTagsUnwrap() {
        // Given
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        // Then
        XCTAssertEqual(issue.tags?.count, 0, "A new issue should have no tags")

        // When
        issue.addToTags(tag)

        // Then
        XCTAssertEqual(issue.tags?.count, 1, "Adding a tag to an issue should result in a count of 1")
    }

    func testIssueTagsList() {
        // Given
        let tagName = "My Test Tag"
        let noTags = "No tags"

        // When
        let tag = Tag(context: managedObjectContext)
        tag.name = tagName
        let issue = Issue(context: managedObjectContext)

        // Then
        XCTAssertEqual(issue.issueTagsList, noTags, "Tag list should show \(noTags)")

        // When
        issue.addToTags(tag)

        // Then
        XCTAssertEqual(issue.issueTagsList, tagName, "Tag list should show \(tagName)")
    }

    func testIssueTagsSortedCorrectly() {
        // Given
        let tagNameA = "AAA Tag"
        let tagNameB = "BBB Tag"
        let tagNameC = "CCC Tag"

        // When
        let issue = Issue(context: managedObjectContext)

        let tagC = Tag(context: managedObjectContext)
        tagC.name = tagNameC

        issue.addToTags(tagC)

        let tagB = Tag(context: managedObjectContext)
        tagB.name = tagNameB

        issue.addToTags(tagB)

        // Then
        XCTAssertEqual(issue.issueTags[0].name, tagNameB, "First tag name should be \(tagNameB)")
        XCTAssertEqual(issue.issueTags[1].name, tagNameC, "Second tag name should be \(tagNameC)")

        // When
        let tagA = Tag(context: managedObjectContext)
        tagA.name = tagNameA

        issue.addToTags(tagA)

        // Then
        XCTAssertEqual(issue.issueTags[0].name, tagNameA, "First tag name should be \(tagNameA)")
        XCTAssertEqual(issue.issueTags[1].name, tagNameB, "Second tag name should be \(tagNameB)")
        XCTAssertEqual(issue.issueTags[2].name, tagNameC, "Third tag name should be \(tagNameC)")
    }

    func testIssueSortingIsStable() {
        // Given
        let issue1 = Issue(context: managedObjectContext)
        issue1.title = "B Issue"
        issue1.creationDate = .now

        let issue2 = Issue(context: managedObjectContext)
        issue2.title = "B Issue"
        issue2.creationDate = .now.addingTimeInterval(1)

        let issue3 = Issue(context: managedObjectContext)
        issue1.title = "A Issue"
        issue1.creationDate = .now.addingTimeInterval(100)

        // When
        let allIssues = [issue1, issue2, issue3]
        let sorted = allIssues.sorted()

        // Then
        XCTAssertEqual([issue3, issue1, issue2], sorted, "Issues should be sorted after title then time.")
    }

    // Test Tags Extension
    func testTagIDUnwrap() {
        // Given
        let tag = Tag(context: managedObjectContext)

        // When
        tag.id = UUID()

        // Then
        XCTAssertEqual(tag.id, tag.tagID, "Tag.id and Tag.tagId should be equal")
    }

    func testTagNameUnwrap() {
        // Given
        let tag = Tag(context: managedObjectContext)
        let tagName = "My tag name"

        // Then
        XCTAssertEqual(tag.tagName, "", "tag name should be empty when created")

        // When
        tag.name = tagName

        // Then
        XCTAssertEqual(tag.tagName, tag.name, "tagname and tag.name should be: \(tagName)")
    }

    func testTagActiveIssues() {
        // Given
        var issues = [Issue]()
        let tag = Tag(context: managedObjectContext)

        // When
        tag.name = "The only tag"

        // Then
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "There should be no active Issue connected to tag.")

        // When
        for index in 0..<10 {
            let issue = Issue(context: managedObjectContext)
            issue.title = "This is issue \(index)"
            issue.addToTags(tag)
            issues.append(issue)
        }

        // Then
        XCTAssertEqual(tag.tagActiveIssues.count, issues.count, "All issues should be active")

        // When
        var numCompleted = 0
        for issue in issues {
            let completed = Bool.random()
            issue.completed = completed
            if completed {
                numCompleted += 1
            }
        }

        // Then
        XCTAssertEqual(tag.tagActiveIssues.count, issues.count - numCompleted,
                       "Only \(issues.count - numCompleted) should be active")
    }

    func testTagSortingIsStable() {
        // Given
        let tag1 = Tag(context: managedObjectContext)
        tag1.name = "B Tag"
        tag1.id = UUID()

        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "B Tag"
        tag2.id = UUID(uuidString: "FFFFFFFF-FFFF-4C91-BB9E-DF5B46D00098")

        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "A Tag"
        tag3.id = UUID()

        // When
        let allTags = [tag1, tag2, tag3]
        let orderedTags = allTags.sorted()

        // Then
        XCTAssertEqual([tag3, tag1, tag2], orderedTags, "Tags should be ordered by name then by uuid.")
    }

    func testBundleDecodingAwards() {
        // Given
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)

        // Then
        XCTAssertFalse(awards.isEmpty, "Awards array should not be empty.")
    }

    func testDecodingString() {
        // Given
        let bundle = Bundle(for: ExtensionTests.self)

        // When
        let data = bundle.decode("DecodableString.json", as: String.self)

        // Then
        XCTAssertEqual(data, "Never ask a starfish for directions.",
                       "Data should be: 'Never ask a starfish for directions.'")
    }

    func testDecodingDictionary() {
        // Given
        let bundle = Bundle(for: ExtensionTests.self)

        // When
        let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)

        // Then
        XCTAssertEqual(data.count, 3, "Data should contain 3 entries")
        XCTAssertEqual(data["One"], 1, "data[\"One\"] should be 1.")
        XCTAssertEqual(data["Two"], 2, "data[\"Two\"] should be 2.")
        XCTAssertEqual(data["Three"], 3, "data[\"Three\"] should be 3.")
    }
}
