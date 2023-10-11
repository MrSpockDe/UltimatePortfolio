//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Albert on 07.10.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var issues: [Issue] {
        let filter = dataController.selectedFilter ?? .all
        
        var allIssues: [Issue]
        
        if let tag = filter.tag {
            // core data entity tag has a to-many relationship to issue
            // therefore the is an NSSet called issues
            allIssues = tag.issues?.allObjects as? [Issue] ?? []
        } else {
            // no tag is seleced therefore .all or .recent is assumed and all issues will
            // be loaded from core data
            let request = Issue.fetchRequest()
            // this predicate will use the modificationDate to either select
            // .all or .recent
            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }
        
        return allIssues.sorted()
    }
    
    var body: some View {
        List {
            ForEach(issues) { issue in
               IssueRow(issue: issue)
            }
            .navigationTitle("Issues")
        }
    }
}

#Preview {
    ContentView()
}
