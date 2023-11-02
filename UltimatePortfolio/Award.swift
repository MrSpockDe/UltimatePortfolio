//
//  Award.swift
//  UltimatePortfolio
//
//  Created by Albert on 02.11.23.
//

import Foundation

struct Award: Decodable, Identifiable {
    var id: String { name }
    var name: String
    var description: String
    var color: String
    var criterion: String
    var value: Int
    var image: String
    
    static var allAwards: [Award] = Bundle.main.decode("Awards.json")
    static var example = allAwards[0]
}
