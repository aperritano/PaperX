//
//  DataController.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/4/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Foundation
import CoreData
class DataStoreController {
    
    private var _managedObjectContext: NSManagedObjectContext
    
    var managedObjectContext: NSManagedObjectContext? {
        guard let coordinator = _managedObjectContext.persistentStoreCoordinator else {
            return nil
        }
        if coordinator.persistentStores.isEmpty {
            return nil
        }
        return _managedObjectContext
    }
    
    let managedObjectModel: NSManagedObjectModel
    let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    var error: NSError?
    
    func inContext(callback: NSManagedObjectContext? -> Void) {
        // Dispatch the request to our serial queue first and then back to the context queue.
        // Since we set up the stack on this queue it will have succeeded or failed before
        // this block is executed.
        dispatch_async(queue) {
            guard let context = self.managedObjectContext else {
                callback(nil)
                return
            }
            
            context.performBlock {
                callback(context)
            }
        }
    }
    
    private let queue: dispatch_queue_t
    
    init(modelUrl: NSURL, storeUrl: NSURL, concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType) {
        
        guard let modelAtUrl = NSManagedObjectModel(contentsOfURL: modelUrl) else {
            fatalError("Error initializing managed object model from URL: \(modelUrl)")
        }
        managedObjectModel = modelAtUrl
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        _managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        _managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        print("Initializing persistent store at URL: \(storeUrl.path!)")
        
        let dispatch_queue_attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0)
        queue = dispatch_queue_create("DataStoreControllerSerialQueue", dispatch_queue_attr)
        
        dispatch_async(queue) {
            do {
                try self.persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: options)
            } catch let error as NSError {
                print("Unable to initialize persistent store coordinator:", error)
                self.error = error
            } catch {
                fatalError()
            }
        }
    }

    // MARK: - Create Configuration object
//    func createConfiguration() -> Configuration {
//        let configurationEntityDescription = NSEntityDescription.entityForName("Configuration", inManagedObjectContext: _managedObjectContext)
//        let newConfiguration = NSManagedObject(entity: configurationEntityDescription!, insertIntoManagedObjectContext: _managedObjectContext)
//        return newConfiguration as! Configuration
//    }
    
    func createSession() -> Session {
        let sessionEntityDescription = NSEntityDescription.entityForName("Session", inManagedObjectContext: _managedObjectContext)
        let newSession = NSManagedObject(entity: sessionEntityDescription!, insertIntoManagedObjectContext: _managedObjectContext)
        return newSession as! Session
    }
    
    func createPaperEntry() -> PaperEntry {
        let paperEntityDescription = NSEntityDescription.entityForName("PaperEntry", inManagedObjectContext: _managedObjectContext)
        let newPaper = NSManagedObject(entity: paperEntityDescription!, insertIntoManagedObjectContext: _managedObjectContext)
        return newPaper as! PaperEntry
    }
    
    func fetchSessions(){
    
        let sessionFetch = NSFetchRequest(entityName: "Session")
        
        do {
            let fetchedSessions = try _managedObjectContext.executeFetchRequest(sessionFetch) as! [Session]
            print(fetchedSessions)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }

    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if _managedObjectContext.hasChanges {
            do {
                try _managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}