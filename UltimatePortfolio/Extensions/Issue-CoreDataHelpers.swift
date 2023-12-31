//
//  Issue-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Albert on 11.10.23.
//

import Foundation
import SwiftUI

extension Issue {
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueCreationDate: Date {
        creationDate ?? .now
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }

    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }

    var issueTagsList: String {
        let noTag = String(localized: "No tags")
        guard let tags else { return noTag }

        if tags.count == 0 {
            return noTag
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }

    var issueReminderTime: Date {
        get { reminderTime ?? .now }
        set { reminderTime = newValue}
    }

    var issueStatus: some View {
        HStack {
            Image(systemName: completed ? "checkmark.square" : "xmark.app")
                .foregroundStyle(completed ? .green : .red)
                .font(.title)
            Text(completed ? "CLOSED" : "OPEN")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }
}

extension Issue: Comparable {
    public static func < (lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
