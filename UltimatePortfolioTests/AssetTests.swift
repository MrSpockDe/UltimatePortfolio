//
//  AssetTests.swift
//  UltimatePortfolioTests
//
//  Created by Albert on 11.11.23.
//

import XCTest
@testable import UltimatePortfolio

final class AssetTests: XCTestCase {
    func testColorsExist() {
        let allColors = ["My Dark Blue",
                         "My Dark Gray",
                         "My Gold",
                         "My Gray",
                         "My Green",
                         "My Light Blue",
                         "My Midnight",
                         "My Orange",
                         "My Pink",
                         "My Purple",
                         "My Red",
                         "My Teal"]
        for color in allColors {
            XCTAssertNotNil(UIColor(named: color),
                            "failed to load color \(color) from asset catalog.")
        }
    }

    func testAwardsLoadCorrectly() {
        XCTAssertTrue(!Award.allAwards.isEmpty, "Failed to load awards from JSON")
    }
}
