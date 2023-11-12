//
//  UserFilterRow.swift
//  UltimatePortfolio
//
//  Created by Albert on 05.11.23.
//

import SwiftUI

struct UserFilterRow: View {
    var filter: Filter

    // these two function work as "callback" so
    // the view showing the userFilterRows decides what
    // to do, if user selectes delete or rename
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void

    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.activeFilterCount)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                // accessibiltyconsideration
                .accessibilityElement()
                .accessibilityLabel(filter.name)
                .accessibilityHint("\(filter.activeFilterCount) issues")
        }
    }
}

#Preview {
    UserFilterRow(filter: .all, rename: { _ in }, delete: { _ in })
}
