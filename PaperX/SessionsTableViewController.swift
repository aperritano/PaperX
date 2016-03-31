//
//  SessionsTableViewController.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/4/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import MobileCoreServices

class SessionsTableController: CoreDataTableViewController, UIDocumentPickerDelegate {


    let database = CKContainer.defaultContainer().privateCloudDatabase
    let recordType = "MyCar"
    let maker = "carmaker"
    let model = "Some model name"
    
    let subscriptionId = "MySubscriptionIdentifier"
    let backgroundTaskName = "saveNewCar"
    /* The background task identifier for the task that will save our record in the database when our app goes to the background */
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    
    
    
    // Mark: - Properties
    // 2
    override func initializeFetchedResultsController() {
        let fetchRequest = NSFetchRequest()
        
        let context = dataController!.managedObjectContext
        let entity = NSEntityDescription.entityForName("Session", inManagedObjectContext: context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20

        
//        var sectionKey: String!
        
        let sortDescriptor1 = NSSortDescriptor(key: "title", ascending: true)
        let sortDescriptors = NSArray(objects: sortDescriptor1)
        fetchRequest.sortDescriptors = sortDescriptors as? [NSSortDescriptor]
//        sectionKey = "title"
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "sessionCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        // Configure the cell...
        self.configureCell(cell, indexPath: indexPath)
        
        
        return cell
    }
    

    // MARK: - UITableViewDataSource
    
    override func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let sessionObj = fetchedResultsController.objectAtIndexPath(indexPath) as! Session
        let sessionCell = cell as! SessionTableCell
        sessionCell.titleLabel?.text = sessionObj.valueForKey("title") as! String!
    
        var counts = 0;
        
        if (sessionObj.papers?.count) != nil {
            
            sessionCell.totalPaper!.text = "Paper Count \(String(sessionObj.papers!.count))"
            for paperEntry in sessionObj.papers! as! Set<PaperEntry> {
                //print(" paper entry \(paperEntry.isLiked)")
                if let liked = paperEntry.isLiked {
                    if liked == true {
                     counts += 1
                    }
                }
                
            }
            //print(" we got \(counts) likes")
            sessionCell.likesLabel.text = "Liked \(counts)"
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .ShortStyle
//        
        if let last_modified = sessionObj.valueForKey("last_modified") {
            let dateString = formatter.stringFromDate(last_modified as! NSDate)
            sessionCell.timestampLabel?.text = dateString
        }
    }
    
    override func removeTableRow(indexPath: NSIndexPath) {
        LOG.debug("\(indexPath.row)")
        let selectedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Session
        
        self.dataController!.deleteSession(selectedObject)
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            
        }
        

//        self.tableView.reloadData()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
//    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.sourceViewController as? MealViewController, meal = sourceViewController.meal {
//            if let selectedIndexPath = tableView.indexPathForSelectedRow {
//                // Update an existing meal.
//                meals[selectedIndexPath.row] = meal
//                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
//            } else {
//                // Add a new meal.
//                let newIndexPath = NSIndexPath(forRow: meals.count, inSection: 0)
//                meals.append(meal)
//                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
//            }
//        }
//    }
    
    func fetchPaperEntry(uuid: String) {
      
        let fr = NSFetchRequest(entityName: "PaperEntry")
            fr.sortDescriptors = [NSSortDescriptor(key: "last_modified", ascending: true)]
        
        
//        let resultPredicate1 = NSPredicate(format: "parent.uuid  == %@ ", "AEB91DA6-AA0D-45A2-A0ED-7E188F2AE385")
        let resultPredicate2 = NSPredicate(format: "isLiked == false")
        
        let compound:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [resultPredicate2])
        
        
        fr.predicate = compound
        
        do {
        let results = try self.dataController?.managedObjectContext.executeFetchRequest(fr)
                    print(" \(results!.count) results changed")
        } catch {
            
        }

        
      
    }
    
    //Mark: - UIDocumentPickerDelegate
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        //print("document picker \(url)")
        
        let filename = url.URLByDeletingPathExtension?.lastPathComponent    
        
        let items = RISFileParser.readFile(url.path!)
        
        //test read
        
        self.dataController?.saveResults(filename!, results: items)
        //parse document
    }
    
    @IBAction func addSessionObj(sender: AnyObject) {
            print("added session")
        let session = dataController!.createSession()
        
        session.setValue(String.random(10, "A"..."z"), forKey: "title")
        session.setValue(NSDate(), forKey:"last_modified")
        session.uuid = NSUUID().UUIDString
        //session.papers = Set<PaperEntry>()
    
    
        dataController!.saveContext()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch let nserror as NSError {
            let title = NSLocalizedString("Error Saving Entity", comment: "Error Saving Entity")
            let message = NSLocalizedString("Error was : \(nserror.description), quitting", comment: "Error was : \(nserror.description), quitting")
            
            print(title)
            print(message)
        } catch {
            
        }
        
    }
    
    @IBAction func addChooseObj(sender: AnyObject) {
        let documentUTIs: NSArray = [ kUTTypePlainText,  kUTTypeText , kUTTypeContent, kUTTypeItem, kUTTypeFileURL, kUTTypeData]
        
//        kUTTypeXML, kUTTypeLog, kUTTypePDF, kUTTypeItem, kUTTypeFileURL, kUTTypeJSON ]

        
        let documentPickerController = CloudUIDocumentPickerViewController(documentTypes: documentUTIs as! [String], inMode: .Import)
        documentPickerController.delegate = self
        documentPickerController.modalPresentationStyle = .FormSheet
        documentPickerController.modalTransitionStyle = .CoverVertical
        
      
//        documentPickerController.navigationController?.navigationBar
//        documentPickerController.navigationController?.navigationBar.barStyle = .Black
//        documentPickerController.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
//        documentPickerController.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        documentPickerController.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        
//        documentPickerController.navigationController?.navigationBarHidden = true

        
        presentViewController(documentPickerController, animated: true, completion: nil)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        //let sessionDetailVC = segue.destinationViewController as! SessionDetailsViewController
        let sessionDetailVC = segue.destinationViewController as! CardUIViewController
        
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        let selectedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Session
        sessionDetailVC.selectedSession = selectedObject
        let p = selectedObject.papers!.allObjects as! [PaperEntry]
        
        let paperNotLiked = p.filter( {$0.isLiked == nil })
        print("not liked \(paperNotLiked.count)")
        sessionDetailVC.papers = p.filter( {$0.isLiked == nil })
        //let index = tableView.indexPathForSelectedRow!.row
        
    }

    func subscription() -> CKSubscription{
        let predicate = NSPredicate(format: "maker == %@", maker)
        let subscription = CKSubscription(recordType: recordType, predicate: predicate,subscriptionID: subscriptionId,options: .FiresOnRecordCreation)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertLocalizationKey = "creationAlertBodyKey"
        
        notificationInfo.shouldBadge = false
        notificationInfo.desiredKeys = ["model"]
        notificationInfo.alertActionLocalizationKey = "creationAlertActionKey"
        subscription.notificationInfo = notificationInfo
        return subscription
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        /* Store information about a Volvo V50 car */
//        let volvoV50 = CKRecord(recordType: "Car")
//        volvoV50.setObject("bob", forKey: "maker")
//        volvoV50.setObject("V50", forKey: "model")
//        volvoV50.setObject(5, forKey: "numberOfDoors")
//        volvoV50.setObject(2015, forKey: "year")
//        
//        
////        fetchPaperEntry("Dfd")
//        /* Save this record publicly */
//        
//        
//        database.saveRecord(volvoV50, completionHandler: { (record, error) -> Void in
//            if (error != nil) {
//                print(error)
//            } else {
//                NSLog("Saved in cloudkit")
//                
//            }
//        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("will appear")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            do {
                try self.fetchedResultsController.performFetch()
                
                self.tableView.reloadData()

            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }

        })
        
    }   
    
    func appCameToForeground(notification: NSNotification){
        print("Application came to the foreground")
        if self.backgroundTaskIdentifier != UIBackgroundTaskInvalid {
            print("We need to invalidate our background task")
            UIApplication.sharedApplication().endBackgroundTask(
            self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
        }
    }
    
    func goAheadAfterPushNotificationRegistration(notification: NSNotification!){
        print("We are asked to proceed because notifications are registered...")
        print("Trying to find the subscription...")

    }
    

    
    

  
}