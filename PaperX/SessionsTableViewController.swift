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
        let cellIdentifier = "HeroListCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        self.configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
 
    // MARK: - UITableViewDataSource
    
    override func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let aHero = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        cell.textLabel?.text = aHero.valueForKey("title") as! String!
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
//        
        if let last_modified = aHero.valueForKey("last_modified") {
            let dateString = formatter.stringFromDate(last_modified as! NSDate)
            cell.detailTextLabel?.text = dateString
        }
    }
    
    //Mark: - UIDocumentPickerDelegate
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        //print("document picker \(url)")
        
        let filename = url.URLByDeletingPathExtension?.lastPathComponent
        
        //let filename = fileURL.URLByDeletingPathExtension?.lastPathComponent
//        let ext = url.pathExtension
//        print(filename)
//        print(ext)
        
     
    
        
        
        //test read
        //let filePath = NSBundle.mainBundle().pathForResource("example", ofType: "ris")
        
        let items = RISFileParser.readFile(url.path!)
        
//        print(url.path)
        
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
        }
        
    }
    
    @IBAction func addChooseObj(sender: AnyObject) {
        print("choose object")
        
        
        let documentUTIs: NSArray = [ kUTTypePlainText,  kUTTypeText , kUTTypeContent ]
        
//        kUTTypeXML, kUTTypeLog, kUTTypePDF, kUTTypeItem, kUTTypeFileURL, kUTTypeJSON ]

        
        let documentPickerController = UIDocumentPickerViewController(documentTypes: documentUTIs as! [String], inMode: .Import)
        documentPickerController.delegate = self

        
        presentViewController(documentPickerController, animated: true, completion: nil)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let sessionDetailVC = segue.destinationViewController as! SessionDetailsViewController
        
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        let selectedObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Session
        sessionDetailVC.selectedSession = selectedObject
        
        let index = tableView.indexPathForSelectedRow!.row
        print("\(index) selected from sesssion")
//        secondVC.selectedCollege = colleges[index]
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
        
        
        /* Store information about a Volvo V50 car */
        let volvoV50 = CKRecord(recordType: "Car")
        volvoV50.setObject("Volvo", forKey: "maker")
        volvoV50.setObject("V50", forKey: "model")
        volvoV50.setObject(5, forKey: "numberOfDoors")
        volvoV50.setObject(2015, forKey: "year")
        
        /* Save this record publicly */
        
        
        database.saveRecord(volvoV50, completionHandler: { (record, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                NSLog("Saved in cloudkit")
                
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        
       
    }

  
}