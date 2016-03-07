//
//  Session+CoreDataProperties.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/6/16.
//  Copyright © 2016 so.raven. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Session {

    @NSManaged var last_modified: NSDate?
    @NSManaged var title: String?
    @NSManaged var uuid: String?
    @NSManaged var papers: NSSet?

}
