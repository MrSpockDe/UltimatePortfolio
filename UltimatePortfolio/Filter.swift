//
//  Filter.swift
//  UltimatePortfolio
//
//  Created by Albert on 09.10.23.
//

import Foundation

let allIssuesName = String(localized: "All Issues")
let recentIssuesName = String(localized: "Recent Issues")

// Filter is used to store the values for a "smart mailbox" function or a tag filter
struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var tag: Tag?
    
    var activeFilterCount: Int {
        tag?.tagActiveIssues.count ?? 0
    }
    
    static var all = Filter(id: UUID(), name: allIssuesName, icon: "tray")
    static var recent = Filter(id: UUID(), name: recentIssuesName, icon: "clock", minModificationDate: .now.addingTimeInterval(86400 * -7))
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
