//
//  DataController.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/5/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Foundation
import CoreData

class DataController: NSObject {
    var managedObjectContext: NSManagedObjectContext
    override init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource("PaperX", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.URLByAppendingPathComponent("PaperX.sqlite")
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//            let docURL = urls[urls.endIndex-1]
//            /* The directory the application uses to store the Core Data store file.
//             This code uses a file named "DataModel.sqlite" in the application's documents directory.
//             */
//            let storeURL = docURL.URLByAppendingPathComponent("PaperX.sqlite")
//            do {
//                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
//            } catch {
//                fatalError("Error migrating store: \(error)")
//            }
//        }
    }
    // MARK: - Create Configuration object
//    func createConfiguration() -> Configuration {
//        let configurationEntityDescription = NSEntityDescription.entityForName("Configuration", inManagedObjectContext: managedObjectContext)
//        let newConfiguration = NSManagedObject(entity: configurationEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
//        return newConfiguration as! Configuration
//    }
    
    func saveResults(title:String, results:[[String:AnyObject]]) {
        let session = self.createSession()
        session.setValue(title, forKey: "title")
        session.setValue(NSDate(), forKey:"last_modified")
        session.uuid = NSUUID().UUIDString
        
        var risEntries = Set<PaperEntry>()
        
        for risEntry in results {
            let pe = self.createPaperEntry()
            pe.uuid = NSUUID().UUIDString
            pe.populateEndnote(risEntry)
            risEntries.insert(pe)
        }
        
        session.papers = risEntries
        self.saveContext()
    }
    func createSession() -> Session {
        let sessionEntityDescription = NSEntityDescription.entityForName("Session", inManagedObjectContext: managedObjectContext)
        let newSession = NSManagedObject(entity: sessionEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        return newSession as! Session
    }
    
    func createPaperEntry() -> PaperEntry {
        let paperEntityDescription = NSEntityDescription.entityForName("PaperEntry", inManagedObjectContext: managedObjectContext)
        let newPaper = NSManagedObject(entity: paperEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        return newPaper as! PaperEntry
    }
    
//    func fetchConfiguration() -> [Configuration] {
//        let configurationFetch = NSFetchRequest(entityName: "Configuration")
//        
//        do {
//            let fetchedConfigurations = try managedObjectContext.executeFetchRequest(configurationFetch) as! [Configuration]
//            return fetchedConfigurations
//        } catch {
//            fatalError("Failed to fetch Sessions: \(error)")
//        }
//        
//        return []
//        
//    }
    
    func deleteSession(session:Session) {
        self.managedObjectContext.deleteObject(session)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            do {
                LOG.debug("DELETING \(session.uuid)")
                try self.managedObjectContext.save()
                
            } catch {
                let saveError = error as NSError
                LOG.debug("\(saveError)")
            }
        
        })

       
    }
    func updatePaperEntry(paperEntry: PaperEntry) {
        let entity = paperEntry as NSManagedObject
        do {
            try entity.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }
    
    func fetchSession(uuid: String) -> Session {
        let sessions = fetchSessions()
        
        let found = sessions.filter( {$0.uuid == uuid })
        return found[0]
    }

    
    func fetchSessions() -> [Session] {
        let sessionFetch = NSFetchRequest(entityName: "Session")
        
        do {
            let fetchedSessions = try managedObjectContext.executeFetchRequest(sessionFetch) as! [Session]
            return fetchedSessions
        } catch {
            fatalError("Failed to fetch Sessions: \(error)")
        }
        return []
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
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