//
//  TagsMenuView.swift
//  UltimatePortfolio
//
//  Created by Albert on 05.11.23.
//

import SwiftUI

struct TagsMenuView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        Menu {
            // show selected Tags first
           ForEach(issue.issueTags) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }
            
            
            // show unselected tags
            let unselectedTags = dataController.missingTags(from: issue)
            let notEmpty = !unselectedTags.isEmpty
            
            if notEmpty {
                Divider()
                
                Section("Add Tags") {
                    ForEach(unselectedTags) { tag in
                        Button(tag.tagName) {
                            issue.addToTags(tag)
                        }
                    }
                }
                
            }  // endIf notEmpty
        } label: {
            Text(issue.issueTagsList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagsList)
        }    }
}

#Preview {
    TagsMenuView(issue: Issue.example)
        .environmentObject(DataController(inMemory: true))
}
