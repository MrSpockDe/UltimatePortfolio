//
//  SmartFilterRow.swift
//  UltimatePortfolio
//
//  Created by Albert on 05.11.23.
//

import SwiftUI

struct SmartFilterRow: View {
    var filter: Filter

    // the NavigationLink is shown inside
    // a NavigationSplitView defined in UltimatePortfolioApp
    // therefore the view is content: ContentView and the
    // value used there is the corresponding filter
    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
        }
    }
}

#Preview {
    SmartFilterRow(filter: Filter.all)
}
