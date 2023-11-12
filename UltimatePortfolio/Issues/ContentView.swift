//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Albert on 07.10.23.
//

import SwiftUI

/// Contenview shows a list of all filters available, that can be applied
/// and a search bar
///
/// The search bar accepts text, that will be searched in
/// the title and description of all issues, and it will also allow
/// to select tags (as token) thgat shall be used additionally
/// for filtering
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
        .searchable(
            text: $dataController.filterText,
            tokens: $dataController.filterTokens,
            suggestedTokens: $dataController.suggestedFilterTokens,
            prompt: "Filter issues or type # to add tags") { tag in
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
