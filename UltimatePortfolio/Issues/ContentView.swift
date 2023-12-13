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
    @StateObject private var viewModel: ViewModel
    @Environment(\.requestReview) var requestReview

    var body: some View {
        List(selection: $viewModel.selectedIssue) {
            ForEach(viewModel.dataController.issueForSelectedFilter()) { issue in
               IssueRow(issue: issue)
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Issues")
        .searchable(
            text: $viewModel.filterText,
            tokens: $viewModel.filterTokens,
            suggestedTokens: $viewModel.suggestedFilterTokens,
            prompt: "Filter issues or type # to add tags") { tag in
            Text(tag.tagName)
        }
        .toolbar(content: ContentViewToolbar.init)
        .onAppear(perform: askForReview)
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()
        }
    }
}

#Preview {
    ContentView(dataController: DataController.preview)
}
