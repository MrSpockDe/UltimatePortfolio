//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Albert on 07.10.23.
//

import CoreData

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = .all
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        container.loadPersistentStores{ storeDescription, error in
            if let error {
                fatalError("Fatal error loading srtore: \(error.localizedDescription)")
            }
        }
    }
    
    func createSampleData() {
        let viewContext = container.viewContext
        
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }
        
        try? viewContext.save()
    }
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
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
        // this execution deleted the elements on sql level direct in the database
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            // since the resulttype is .resultTypeObjectIDs, the result is an array
            // of NSManagedObjectID
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            // the objects in memory do not know about the deletion in the database
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
}
