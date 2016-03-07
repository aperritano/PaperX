//
//  ViewController.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/3/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import UIKit
import CoreData

class SessionDetailsViewController: CoreDataTableViewController {
    
    
    // Mark: - Properties
    // 2
    var selectedSession: Session!
    
    override func initializeFetchedResultsController() {
        let fetchRequest = NSFetchRequest()
        
        let context = dataController!.managedObjectContext
        let entity = NSEntityDescription.entityForName("PaperEntry", inManagedObjectContext: context)
        let paperEntryPredicate = NSPredicate(format: "parent.uuid == %@", self.selectedSession.uuid!)
        fetchRequest.predicate =  paperEntryPredicate
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        
        
        var sectionKey: String!
        
        let sortDescriptor1 = NSSortDescriptor(key: "title", ascending: true)
        let sortDescriptors = NSArray(objects: sortDescriptor1)
        fetchRequest.sortDescriptors = sortDescriptors as? [NSSortDescriptor]
        sectionKey = "title"
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "papersCell"
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
     
    }
    
    @IBAction func addSessionObj(sender: AnyObject) {
        print("added session")
        let session = dataController!.createSession()
        
        session.setValue(String.random(10, "A"..."z"), forKey: "title")
        session.setValue(NSDate(), forKey:"last_modified")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}



