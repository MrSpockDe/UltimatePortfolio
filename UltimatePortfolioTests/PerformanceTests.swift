//
//  PerformanceTests.swift
//  UltimatePortfolioTests
//
//  Created by Albert on 19.11.23.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

final class PerformanceTests: BaseTestCase {
    func testAwardCalculationPerformance() {
        // Given
        for _ in 1...100 {
            dataController.createSampleData()
        }

        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500,
                       "The number of awards used for testing performance was 500")
        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
}
