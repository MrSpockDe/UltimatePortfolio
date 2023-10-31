//
//  IssueView.swift
//  UltimatePortfolio
//
//  Created by Albert on 14.10.23.
//

import SwiftUI

struct IssueView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
        
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
                
                
                HStack {
                    Text("**Status:**")
                        .foregroundStyle(.secondary)
                    issue.issueStatus
                }
                
                
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                .pickerStyle(.segmented)
                
            
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
                }
            }
            
        
            Section {
                VStack(alignment: .leading)  {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField("Description", text: $issue.issueContent, prompt: Text("Enter the issue description here"), axis: .vertical)
                }
            } 
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
    }
    
}

#Preview {
    IssueView(issue: .example)
}
