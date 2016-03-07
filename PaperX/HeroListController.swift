//
//  HeroListController.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/5/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HeroListController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private var _fetchedResultsController: NSFetchedResultsController!
    
    // Mark: - DataController
    var dataController: DataController?
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    // MARK:- FetchedResultsController Property
    private var fetchedResultsController: NSFetchedResultsController {
        get {
            if _fetchedResultsController != nil {
                return _fetchedResultsController
            }
            
            let fetchRequest = NSFetchRequest()
            
            let context = dataController!.managedObjectContext
            let entity = NSEntityDescription.entityForName("Session", inManagedObjectContext: context)
            fetchRequest.entity = entity
            fetchRequest.fetchBatchSize = 20
            
            
            
            var sectionKey: String!
            
                let sortDescriptor1 = NSSortDescriptor(key: "title", ascending: true)
                let sortDescriptors = NSArray(objects: sortDescriptor1)
                fetchRequest.sortDescriptors = sortDescriptors as? [NSSortDescriptor]
                sectionKey = "title"
            
            let aFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            aFetchResultsController.delegate = self
            _fetchedResultsController = aFetchResultsController
            return _fetchedResultsController
        }
    }
    
    @IBAction func addSession(sender: UIBarButtonItem) {
        print("added session")
//        let  managedObjectContext = fetchedResultsController.managedObjectContext as
//        NSManagedObjectContext
//        let entity:NSEntityDescription = fetchedResultsController.fetchRequest.entity!
//        NSEntityDescription.insertNewObjectForEntityForName(entity.name!,
//                                                            inManagedObjectContext: managedObjectContext)
        
//        let foundConfiguration = dataController.fetchConfiguration()
//        let configuration = foundConfiguration[0]
//        
//        print("last modified \(configuration.last_modified)")
//        print("sessions \(configuration.sessions)")
//        
//        let sessions = configuration.mutableSetValueForKey("sessions")
//        
        let session = dataController!.createSession()
        
        
        session.setValue(String.random(10, "A"..."z"), forKey: "title")
        session.setValue(NSDate(), forKey:"last_modified")
        

        
        dataController!.saveContext()
        
        
        do {
            //try managedObjectContext.save()
            
            
            try self.fetchedResultsController.performFetch()
            
        } catch let nserror as NSError {
            let title = NSLocalizedString("Error Saving Entity", comment: "Error Saving Entity")
            let message = NSLocalizedString("Error was : \(nserror.description), quitting", comment: "Error was : \(nserror.description), quitting")
            showAlertWithCompletion("title", message:"message", buttonTitle:"Aw nuts", completion:{_ in exit(-1)})
        }
        
    }
    
    func showAlertWithCompletion(title:String, message:String,
                                 buttonTitle:String = "OK", completion:((UIAlertAction!)->Void)!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .Default, handler: completion)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        //let session = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Session
        
        
        let aHero = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        cell.textLabel?.text = aHero.valueForKey("title") as! String!
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        
//        let dateString = formatter.stringFromDate(aHero.valueForKey("last_modified") as! NSDate!)
//        
//        
//        cell.detailTextLabel?.text = dateString
        
        // Populate cell from the NSManagedObject instance
    }
    
    // MARK: - NSFetchedResultsController Delegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - TableView Methods

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "HeroListCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        self.configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        dataController = appDelegate.dataController
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //Selet the TabBar button
        let defaults = NSUserDefaults.standardUserDefaults()
        
        //
        self.navigationItem.rightBarButtonItem = self.addButton
        
        //Fetch any existing entities
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch var error1 as NSError {
            error = error1
            let title = NSLocalizedString("Error Saving Entity", comment: "Error Saving Entity")
            let message = NSLocalizedString("Error was : \(error?.description), quitting",
                                            comment: "Error was : \(error?.description), quitting")
            showAlertWithCompletion(title, message: message,
                                    buttonTitle: "Aw nuts", completion: { _ in exit(-1)})
        }
//        if !fetchedResultsController.performFetch(error) {
//            let title = NSLocalizedString("Error Saving Entity", comment: "Error Saving Entity")
//            let message = NSLocalizedString("Error was : \(error?.description), quitting",
//                                            comment: "Error was : \(error?.description), quitting")
//            showAlertWithCompletion(title, message: message,
//                                    buttonTitle: "Aw nuts", completion: { _ in exit(-1)})
//        }
    }
    
//    showAler
//    func showAlertWithCompletion(title:String, message:String, buttonTitle:String = "OK", completion:((UIAlertAction!)->Void)!){
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
//        let okAction = UIAlertAction(title: buttonTitle, style: .Default, handler: completion)
//        alert.addAction(okAction)
//        self.presentViewController(alert, animated: true, completion: nil)
//    }
}
