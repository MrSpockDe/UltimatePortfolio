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

    @State private var showingNotificationError = false
    @Environment(\.openURL) var openURL

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

                TagsMenuView(issue: issue)
            }

            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical)
                }
            }

            Section("Reminders") {
                Toggle("Show reminder", isOn: $issue.reminderEnabled.animation())

                if issue.reminderEnabled {
                    DatePicker(
                        "Reminder time",
                        selection: $issue.issueReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
        .alert("Ooops!", isPresented: $showingNotificationError) {
            Button("Check settings", action: showAppSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(NSLocalizedString("There was a problem setting your notification."
                                   + " Plese check you have notifications enabled.", comment: "There was a problem"))
        }
        .onChange(of: issue.reminderEnabled) { updateReminder() }
        .onChange(of: issue.issueReminderTime) { updateReminder() }
    }

    func showAppSettings() {
        guard let settingsURL = URL(
            string: UIApplication.openNotificationSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }

    func updateReminder() {
        dataController.removeReminders(for: issue)

        Task { @MainActor in
            if issue.reminderEnabled {
                let success = await dataController.addReminder(for: issue)
                if !success {
                    issue.reminderEnabled = false
                    showingNotificationError = true
                }
            }
        }
    }
}

#Preview {
    IssueView(issue: .example)
        .environmentObject(DataController(inMemory: true))
}
