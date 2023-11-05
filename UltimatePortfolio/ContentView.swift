//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Albert on 07.10.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.issueForSelectedFilter()) { issue in
               IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, suggestedTokens: $dataController.suggestedFilterTokens, prompt: "Filter issues or type # to add tags") { tag in
            Text(tag.tagName)
        }
        .toolbar(content: ContentViewToolbar.init)
    }
    
    func delete(_ offsets: IndexSet) {
        let issues = dataController.issueForSelectedFilter()
        
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataController(inMemory: true))
}
