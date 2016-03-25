//
//  PaperEntry+CoreDataProperties.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/24/16.
//  Copyright © 2016 so.raven. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PaperEntry {

    @NSManaged var abstract: String?
    @NSManaged var acmid: String?
    @NSManaged var address: String?
    @NSManaged var authors: NSObject?
    @NSManaged var booktitle: String?
    @NSManaged var databasePublisher: String?
    @NSManaged var databaseURL: String?
    @NSManaged var doi: String?
    @NSManaged var endPage: String?
    @NSManaged var entryType: String?
    @NSManaged var inproceeding: String?
    @NSManaged var isbn: String?
    @NSManaged var isLiked: NSNumber?
    @NSManaged var isRead: NSNumber?
    @NSManaged var keywords: String?
    @NSManaged var last_modified: NSDate?
    @NSManaged var location: String?
    @NSManaged var numpages: String?
    @NSManaged var pages: String?
    @NSManaged var published: String?
    @NSManaged var publisher: String?
    @NSManaged var rawEntry: NSObject?
    @NSManaged var series: String?
    @NSManaged var startPage: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var volume: String?
    @NSManaged var year: String?
    @NSManaged var uuid: String?
    @NSManaged var parent: Session?

}
