//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Albert on 09.10.23.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataController: DataController

    let smartFilters: [Filter] = [.all, .recent]

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>

    // renaming of filters shall be done in a sheet
    // that is presented when renamimgTag gets true
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""

    // generate an array of filters by their name
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }

    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: rename, delete: delete)
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar(content: SidebarViewToolbar.init)
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $tagName)
        }
        .navigationTitle("Filters")
    }

    // delete delets a set of tags from the
    // tags array in memory and on disk by calling
    // the delete function of the datacontroller
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }

    // when a filter shall be deleted that is based on a tag
    // the tag willbe deleted from Core Data Store
    func delete(_ filter: Filter) {
        guard let tag = filter.tag else { return }
        dataController.delete(tag)
        dataController.save()
    }

    // filters will have a default name that
    // can be changed using a sheet
    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagName = filter.name
        renamingTag = true
    }

    // if the new name shall be used
    // for the filter completeRename shall be called
    // to make the changespermanent
    func completeRename() {
        tagToRename?.name = tagName
        dataController.save()
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
