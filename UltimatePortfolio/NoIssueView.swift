//
//  NoIssueView.swift
//  UltimatePortfolio
//
//  Created by Albert on 14.10.23.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Text("No Issue selected.")
            .font(.title)
            .foregroundColor(.secondary)
        
        Button("New Issue", action: dataController.newIssue)
    }
}

#Preview {
    NoIssueView()
}
