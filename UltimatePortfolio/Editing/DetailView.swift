//
//  DetailView.swift
//  UltimatePortfolio
//
//  Created by Albert on 09.10.23.
//

import SwiftUI

extension View {
    func inlineNavigationBar() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

struct DetailView: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        VStack {
            if let issue = dataController.selectedIssue {
                IssueView(issue: issue)
            } else {
                NoIssueView()
            }
        }
        .navigationTitle("Details")
        .inlineNavigationBar()
    }
}

/*
#Preview {#imageLiteral(resourceName: "simulator_screenshot_97CBA801-2C1C-43F0-9D82-A4659443C29E.png")
    DetailView()
} */
