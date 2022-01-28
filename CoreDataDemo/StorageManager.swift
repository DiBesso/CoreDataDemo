//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Дмитрий Бессонов on 26.01.2022.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager ()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    func fetchData(completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        do {
           let taskList = try viewContext.fetch(fetchRequest)
            completion (.success(taskList))
        } catch let error {
            completion (.failure(error))
        }
    }
    
    func saveSetup(_ task: Task, newName: String) {
        task.name = newName
        saveContext()
    }
    
    func save(_ taskName: String, comletion: (Task) -> Void) {
        let task = Task(context: viewContext)
        task.name = taskName
        comletion(task)
        saveContext()
    }
    
    func delete(_ task: Task) {
        viewContext.delete(task)
        saveContext()
    }
    
    
    // MARK: - Core Data Saving support

    func saveContext () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
