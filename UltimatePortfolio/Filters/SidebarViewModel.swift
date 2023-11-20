//
//  SidebarViewModel.swift
//  UltimatePortfolio
//
//  Created by Albert on 20.11.23.
//

import CoreData
import Foundation

extension SidebarView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        var dataController: DataController

        private let tagController: NSFetchedResultsController<Tag>
        @Published var tags = [Tag]()

        // renaming of filters shall be done in a sheet
        // that is presented when renamimgTag gets true
        @Published var tagToRename: Tag?
        @Published var renamingTag = false
        @Published var tagName = ""

        // generate an array of filters by their name
        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
            }
        }

        init(dataController: DataController) {
            self.dataController = dataController

            let request = Tag.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                keyPath: \Tag.name,
                ascending: true)]

            tagController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil)

            super.init()

            tagController.delegate = self

            do {
                try tagController.performFetch()
                tags = tagController.fetchedObjects ?? []
            } catch {
                print("failed to fetch tags")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTags = controller.fetchedObjects as? [Tag] {
                tags = newTags
            }
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
}
