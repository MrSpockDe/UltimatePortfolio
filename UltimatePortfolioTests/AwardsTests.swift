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
    let awards = Award.allAwards

    func testAwardIdMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name,
                           "Award name (\(award.name)) should match Award id (\(award.id)).")
        }
    }

    func testNewUserHasNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "user should not have earned award \(award.name).")
        }
    }

    func testCreateIssuesForAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        let awards = Award.allAwards

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
                XCTAssertEqual(dataController.hasEarned(award: award),
                               numIssues >= award.value,
                               "award \(award.name) should be unlocked with \(award.value) issues")
            }
        }
    }

    func testCreateClosedIssuesForAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        let awards = Award.allAwards

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
                XCTAssertEqual(dataController.hasEarned(award: award),
                               numIssues >= award.value,
                               "award \(award.name) should be unlocked with \(award.value) issues")
            }
        }
    }

    func testCreateTagsForAwards() {
        let values = [1, 10, 50]
        let awards = Award.allAwards

        var tags = [Tag]()
        for index in 0..<values.count {
            dataController.deleteAll()
            tags.removeAll()

            for _ in 0..<values[index] {

                let mytag = Tag(context: managedObjectContext)
                mytag.name = UUID().uuidString
                tags.append(mytag)
            }

            dataController.save()

            let numTags = dataController.count(for: Tag.fetchRequest())
            // print("numTags: \(numTags)")
            for award in awards where award.criterion == "tags" {
                XCTAssertEqual(dataController.hasEarned(award: award),
                               numTags >= award.value,
                               "award \(award.name) should be unlocked with \(award.value) issues")
            }
        }
    }
}
