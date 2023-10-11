//
//  IssueRow.swift
//  UltimatePortfolio
//
//  Created by Albert on 11.10.23.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        NavigationLink(value: issue) {
            HStack {
                Text(issue.issueTitle)
                Spacer()
                Image(systemName: issue.completed ? "checkmark.rectangle" : "xmark.rectangle")
                    .foregroundColor(issue.completed ? .green : .red)
            }
        }
    }
}

#Preview {
    IssueRow(issue: .example)
}
