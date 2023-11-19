//
//  AwardsTests.swift
//  UltimatePortfolioTests
//
//  Created by Albert on 12.11.23.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

final class AwardsTests: BaseTestCase {
    // Given
    let awards = Award.allAwards

    func testAwardIdMatchesName() {
        // Then
        for award in awards {
            XCTAssertEqual(award.id, award.name,
                           "Award name (\(award.name)) should match Award id (\(award.id)).")
        }
    }

    func testNewUserHasNoAwards() {
        // Then
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "user should not have earned award \(award.name).")
        }
    }

    func testCreateIssuesForAwards() {
        // Given
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        let awards = Award.allAwards

        // When
        var issues = [Issue]()
        for index in 0..<values.count {
            dataController.deleteAll()
            issues.removeAll()

            for _ in 0..<values[index] {

                let myissue = Issue(context: managedObjectContext)
                myissue.title = UUID().uuidString
                issues.append(myissue)
            }

            dataController.save()

            let numIssues = dataController.count(for: Issue.fetchRequest())
            for award in awards where award.criterion == "issues" {
                // Then
                XCTAssertEqual(dataController.hasEarned(award: award),
                               numIssues >= award.value,
                               "award \(award.name) should be unlocked with \(award.value) issues")
            }
        }
    }

    func testCreateClosedIssuesForAwards() {
        // Given
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        let awards = Award.allAwards

        // When
        var issues = [Issue]()
        for index in 0..<values.count {
            dataController.deleteAll()
            issues.removeAll()

            for _ in 0..<values[index] {

                let myissue = Issue(context: managedObjectContext)
                myissue.title = UUID().uuidString
                myissue.completed = true
                issues.append(myissue)
            }

            dataController.save()

            let numIssues = dataController.count(for: Issue.fetchRequest())
            for award in awards where award.criterion == "closed" {
                // Then
                XCTAssertEqual(dataController.hasEarned(award: award),
                               numIssues >= award.value,
                               "award \(award.name) should be unlocked with \(award.value) issues")
            }
        }
    }

    func testCreateTagsForAwards() {
        // Given
        let values = [1, 10, 50]
        let awards = Award.allAwards

        // When
        var tags = [Tag]()
        for index in 0..<values.count {
            dataController.deleteAll()
            tags.removeAll()
            var numEarned = 0

            for _ in 0..<values[index] {

                let mytag = Tag(context: managedObjectContext)
                mytag.name = UUID().uuidString
                tags.append(mytag)
            }

            dataController.save()

            let numTags = dataController.count(for: Tag.fetchRequest())
            // print("numTags: \(numTags)")
            for award in awards where award.criterion == "tags" {
                let earned = dataController.hasEarned(award: award)
                if earned {
                    numEarned += 1
                }
                // Then
                XCTAssertEqual(earned,
                               numTags >= award.value,
                               "award \(award.name) should be unlocked with \(award.value) issues")
            }
            XCTAssertEqual(numEarned, index + 1, "the number of awards \(numEarned) should be \(index + 1)")
        }
    }
}
