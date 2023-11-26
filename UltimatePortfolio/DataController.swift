//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Albert on 07.10.23.
//

import CoreData
import SwiftUI

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

/// Stati for filtering
enum Status {
    case all, open, closed
}

/// An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {

    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer

    /// spotlite search enabling
    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?

    /// Filter currently to be used when showing issues
    @Published var selectedFilter: Filter? = .all

    /// currently selected issue
    @Published var selectedIssue: Issue?

    @Published var filterText = ""

    /// filter tokens is an array containing all tags that shall be considered
    /// when deciding whether an issue should be shown or not.
    ///
    /// All issues are shown that have at least one tag from that list attached.
    @Published var filterTokens = [Tag]()

    /// shall selected filters be used
    @Published var filterEnabled = false

    /// filter priority 0 = low, 1 = medium, 2 = high, -1 = no priority selected
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true

    /// storeTask shall be called as soon as possible
    private var storeTask: Task<Void, Never>?
    /// the saveTask will be executet every few seconds so that
    /// date will not be lost during long editing sessions
    private var saveTask: Task<Void, Error>?
    private var tokenSet = false

    /// User Defaults suite where we are saving  user data
    ///
    /// To prevent hidden dependencies
    let defaults: UserDefaults

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    /// tokens shall be selectable in the seach bar, this propery provides an array
    /// of possible filter tokens, which name starts with the text entered in the
    /// search bar
    ///
    /// selection whether the user uses text or tokens ist done by prefixing a #
    var suggestedFilterTokens: [Tag] {
        get {
            guard filterText.starts(with: "#") else {
                return []
            }

            let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
            let request = Tag.fetchRequest()

            if !trimmedFilterText.isEmpty {
                request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
                // print(trimmedFilterText)
            }

            return (try? container.viewContext.fetch(request).sorted()) ?? []
        }

        set(newTokenList) {
            // print("newTokenList: \(newTokenList)")
            if !newTokenList.isEmpty {
                newTokenList.forEach { item in
                    print(item)
                }
                tokenSet = true
            }
        }
    }

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("failed to locate model file")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("failed to load model")
        }

        return managedObjectModel
    }()

    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.) 
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    /// - Parameter defaults: The UserDefaults Suite where user data should be stored
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        storeTask = Task {
            await monitorTransactions()
        }
        // For testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // Make sure that we watch iCloud for all changes to make
        // absolutely sure we keep our local UI in sync when a
        // remote change happens.
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged)

        container.loadPersistentStores { [weak self] _, error in
            if let error {
                fatalError("Fatal error loading srtore: \(error.localizedDescription)")
            }

            if let description = self?.container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber,
                                      forKey: NSPersistentHistoryTrackingKey)

                if let coordinator = self?.container.persistentStoreCoordinator {
                    self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(
                        forStoreWith: description,
                        coordinator: coordinator)
                    self?.spotlightDelegate?.startSpotlightIndexing()
                }
            }
            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self?.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
        }
    }

    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    func createSampleData() {
        let viewContext = container.viewContext

        for ind in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(ind)"

            for jind in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(ind)-\(jind)"
                issue.content = String(localized: "Description goes here")
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }

    /// Saves our Core Data context if there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    func save() {
        saveTask?.cancel()

        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    func queueSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        // tell me what you will delete (the ids of those objects)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        // execute accepts any request therefore it needs to be casted
        // this execution deleted the elements on sql level directly in the database
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            // since the resulttype is .resultTypeObjectIDs, the result is an array
            // of NSManagedObjectID
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            // ⚠️ the objects in memory do not know about the deletion in the database
            // and thherefore the changes need to be merged with the context
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(fetchRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(fetchRequest2)

        save()
    }

    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)

        return difference.sorted()
    }

    /// Runs a fetch request with various predicates that filter the user's issues based
    /// on tag, title and content text, search tokens, priority, and completion status.
    /// - Returns: An array of all matching issues.
    func issueForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all

        /// all predicates that Core Data shall use to query data
        var predicates = [NSPredicate]()

        // filters are defined in a way that they can be based
        // on tags or on modificationDate
        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }

        // the text filter will search (caseinsensitive) for the
        // entered text in both title and content of issues
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if !trimmedFilterText.isEmpty {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPreicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)

            let filterTextPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPreicate])

            predicates.append(filterTextPredicate)
        }

        // also tokens (in this case that are tags) can be searched for
        // the implementetion use a logical OR to search for tags
        if !filterTokens.isEmpty {
            let tokenPredicate = NSPredicate(format: "ANY tags in %@", filterTokens)
            predicates.append(tokenPredicate)
        }

        // via a dropdown menu filter priority and / or filter status
        // (open or closed) can be added to the filter options
        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityFilter)
            }

            if filterStatus != .all {
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: filterStatus == .closed))
                predicates.append(statusFilter)
            }
        }

        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]

        let allIssues = (try? container.viewContext.fetch(request)) ?? []

        return allIssues
    }

    func newTag() -> Bool {
        var shouldCreate = fullVersionUnlocked
        if !shouldCreate {
            shouldCreate = count(for: Tag.fetchRequest()) < 3
        }
        guard shouldCreate else {
            return false
        }

        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = String(localized: "New Tag")

        save()
        return true
    }

    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = String(localized: "New Issue")
        issue.creationDate = .now
        issue.priority = 1

        // If we're currently browsing a user-created tag, immediately
        // add this new issue to the tag otherwise it won't appear in
        // the list of issues they see.
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        save()
        selectedIssue = issue
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "issues":
            let fetchRequest = Issue.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "closed":
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let closedCount = count(for: fetchRequest)
            return closedCount >= award.value

        case "tags":
            let fetchRequest = Tag.fetchRequest()
            let tagCount = count(for: fetchRequest)
            return tagCount >= award.value

        default:
            // fatalError("unknown award criteria of \(award.criterion)")
            return false
        }
    }

    /// find the issue that is provided as url from spotlight
    func issue(with uniqueIdentifier: String) -> Issue? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }
        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }
        return try? container.viewContext.existingObject(with: id) as?  Issue
    }
}
