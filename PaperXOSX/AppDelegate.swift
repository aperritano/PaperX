//
//  AppDelegate.swift
//  PaperXOSX
//
//  Created by Anthony Perritano on 3/15/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Cocoa
import CoreData
import CloudKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    var dataController: DataController!
//    let container = CKContainer.defaultContainer()
    
    let database = CKContainer(identifier: "iCloud.so.raven.PaperX").privateCloudDatabase
    let fileManager = NSFileManager()
    var userDefaults = NSUserDefaults.standardUserDefaults()
    var documentURL: NSURL?
    var ubiquityURL: NSURL?
    var metaDataQuery: NSMetadataQuery?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
         dataController = DataController()
        print("added session")
        let session = dataController!.createSession()
        
        session.setValue("hello", forKey: "title")
        session.setValue(NSDate(), forKey:"last_modified")
        session.uuid = NSUUID().UUIDString
        //session.papers = Set<PaperEntry>()
        
        
        dataController!.saveContext()
        
//        let recordType = "MyCar"
//        let maker = "tesla"
//        let model = "X"
//        
//        let subscriptionId = "MySubscriptionIdentifier"
//        let backgroundTaskName = "saveNewCar"
        
        /* Store information about a Volvo V50 car */
        let volvoV50 = CKRecord(recordType: "Car")
        volvoV50.setObject("modelx1", forKey: "maker")
        volvoV50.setObject("x", forKey: "model")
        volvoV50.setObject(2, forKey: "numberOfDoors")
        volvoV50.setObject(2016, forKey: "year")
        
        database.saveRecord(volvoV50, completionHandler: { (record, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                NSLog("Saved in cloudkit")
                
            }
        })
        
        /* Save this record publicly */
        
        dispatch_async(dispatch_get_global_queue(Int(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {
            if let iCloud = self.fileManager.URLForUbiquityContainerIdentifier(nil) {
                
                self.ubiquityURL = iCloud
                self.ubiquityURL  = self.ubiquityURL!.URLByAppendingPathComponent("Documents")
                
                
                print("icloud \(self.ubiquityURL)")
                
                self.metaDataQuery = NSMetadataQuery()
                
                self.metaDataQuery?.predicate =
                    NSPredicate(format: "%K like 'savefile.txt'",
                                NSMetadataItemFSNameKey)
                self.metaDataQuery?.searchScopes =
                    [NSMetadataQueryUbiquitousDocumentsScope]
                
                
                
                self.metaDataQuery!.startQuery()
                
                dispatch_async(dispatch_get_main_queue(), {
                    print("do stuff")// doesn't exist
                })
            } else {
                print("not icloud")// doesn't exist
            }
        }

               
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(iCloudAccountAvailabilityChanged(_:)),
                                                         name: NSUbiquityIdentityDidChangeNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(storeDidChange(_:)),
                                                         name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification,
                                                         object: NSUbiquitousKeyValueStore.defaultStore())
        
        
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        // Insert code here to initialize your application
    }
    
    func iCloudAccountAvailabilityChanged(aNotification: NSNotification) {
        print("icloud AVAIL osx")
    }
    
    func storeDidChange(aNotification: NSNotification) {
        print("icloud changed osx")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

//    // MARK: - Core Data stack
//
//    lazy var applicationDocumentsDirectory: NSURL = {
//        // The directory the application uses to store the Core Data store file. This code uses a directory named "so.raven.PaperXOSX" in the user's Application Support directory.
//        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
//        let appSupportURL = urls[urls.count - 1]
//        return appSupportURL.URLByAppendingPathComponent("so.raven.PaperXOSX")
//    }()
//
//    lazy var managedObjectModel: NSManagedObjectModel = {
//        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
//        let modelURL = NSBundle.mainBundle().URLForResource("PaperXOSX", withExtension: "momd")!
//        return NSManagedObjectModel(contentsOfURL: modelURL)!
//    }()
//
//    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
//        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
//        let fileManager = NSFileManager.defaultManager()
//        var failError: NSError? = nil
//        var shouldFail = false
//        var failureReason = "There was an error creating or loading the application's saved data."
//
//        // Make sure the application files directory is there
//        do {
//            let properties = try self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey])
//            if !properties[NSURLIsDirectoryKey]!.boolValue {
//                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
//                shouldFail = true
//            }
//        } catch  {
//            let nserror = error as NSError
//            if nserror.code == NSFileReadNoSuchFileError {
//                do {
//                    try fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil)
//                } catch {
//                    failError = nserror
//                }
//            } else {
//                failError = nserror
//            }
//        }
//        
//        // Create the coordinator and store
//        var coordinator: NSPersistentStoreCoordinator? = nil
//        if failError == nil {
//            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CocoaAppCD.storedata")
//            do {
//                try coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil)
//            } catch {
//                failError = error as NSError
//            }
//        }
//        
//        if shouldFail || (failError != nil) {
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            if failError != nil {
//                dict[NSUnderlyingErrorKey] = failError
//            }
//            let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            NSApplication.sharedApplication().presentError(error)
//            abort()
//        } else {
//            return coordinator!
//        }
//    }()
//
//    lazy var managedObjectContext: NSManagedObjectContext = {
//        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
//        let coordinator = self.persistentStoreCoordinator
//        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        return managedObjectContext
//    }()
//
//    // MARK: - Core Data Saving and Undo support
//
//    @IBAction func saveAction(sender: AnyObject!) {
//        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
//        if !managedObjectContext.commitEditing() {
//            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
//        }
//        if managedObjectContext.hasChanges {
//            do {
//                try managedObjectContext.save()
//            } catch {
//                let nserror = error as NSError
//                NSApplication.sharedApplication().presentError(nserror)
//            }
//        }
//    }
//
//    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
//        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
//        return managedObjectContext.undoManager
//    }
//
//    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
//        // Save changes in the application's managed object context before the application terminates.
//        
//        if !managedObjectContext.commitEditing() {
//            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
//            return .TerminateCancel
//        }
//        
//        if !managedObjectContext.hasChanges {
//            return .TerminateNow
//        }
//        
//        do {
//            try managedObjectContext.save()
//        } catch {
//            let nserror = error as NSError
//            // Customize this code block to include application-specific recovery steps.
//            let result = sender.presentError(nserror)
//            if (result) {
//                return .TerminateCancel
//            }
//            
//            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
//            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
//            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
//            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
//            let alert = NSAlert()
//            alert.messageText = question
//            alert.informativeText = info
//            alert.addButtonWithTitle(quitButton)
//            alert.addButtonWithTitle(cancelButton)
//            
//            let answer = alert.runModal()
//            if answer == NSAlertFirstButtonReturn {
//                return .TerminateCancel
//            }
//        }
//        // If we got here, it is time to quit.
//        return .TerminateNow
//    }

}

