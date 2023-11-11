//
//  AwardsView.swift
//  UltimatePortfolio
//
//  Created by Albert on 02.11.23.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController: DataController

    @State private var selectedAward = Award.example
    @State private var showingAwardsDetails = false

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardsDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(color(for: award))
                        }
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(award.description)
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(awardTitle, isPresented: $showingAwardsDetails) {
        } message: {
            Text(selectedAward.description)
        }
    }
    var awardTitle: String {
        if dataController.hasEarned(award: selectedAward) {
            return String(localized: "Unlocked: \(selectedAward.name)")
        } else {
            return String(localized: "Locked")
        }
    }

    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }

    func label(for award: Award) -> LocalizedStringKey {
        dataController.hasEarned(award: award) ? "Unlocked \(award.name)" : "Locked"
    }
}

#Preview {
    AwardsView()
}
