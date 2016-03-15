//
//  PaperEntry+Helper.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/13/16.
//  Copyright © 2016 so.raven. All rights reserved.
//TY  - CONF
//T1  - Metaphone: machine aesthetics meets interaction design
//A1  - &Scaron;imbelis, Vygandas
//A1  - Lundstr&ouml;m, Anders
//A1  - H&ouml;&ouml;k, Kristina
//A1  - Solsona, Jordi
//A1  - Lewandowski, Vincent
//T2  - Proceedings of ACM CHI 2014 Conference on Human Factors in Computing Systems
//PY  - 2014/04/26
//VL  - 1
//SP  - 1
//EP  - 10
//UR  - http://dx.doi.org/10.1145/2556288.2557152
//AB  - Through our art project, Metaphone, we explored a particular form of
//aesthetics referred to in the arts tradition as machine aesthetics. The
//Metaphone machine collects the participant's bio-data, Galvanic Skin Response
//(GSR) and Heart Rate (HR), creating a process of movement, painting and sound.
//The machine behaves in machine-like, aesthetically evocative ways: a shaft on
//two large wheels rotates on the floor, carrying paint that is dripped onto a
//large sheet of aquarelle paper on the floor according to bio-sensor data. A
//soundscape rhythmically follows the bio-sensor data, but also has its own
//machine-like sounds. Six commentators were invited to interact with the
//machine. They reported a strangely relaxing atmosphere induced by the machine.
//Based on these experiences we discuss how different art styles can help to
//describe aesthetics in interaction design generally, and how machine aesthetics
//in particular can be used to create interesting, sustained, stylistically
//coherent interactions.
//DP  - http://hcibib.org
//DB  - HCI Bibliography
//ER  -


//

import Foundation


extension PaperEntry {
    
    func populateEndnote( properties: [String:AnyObject]) {
        self.rawEntry = properties
        self.entryType = properties["TY"] as? String
        self.abstract = properties["AB"] as? String
        self.acmid = properties["UR"] as? String
        self.authors = properties["A1"] as? [String]
        self.title = properties["T1"] as? String
        self.inproceeding = properties["T2"] as? String
        self.published = properties["PY"] as? String
        self.volume = properties["VL"] as? String
        self.startPage = properties["SP"] as? String
        self.endPage = properties["EP"] as? String
        self.doi = properties["UI"] as? String
        self.databaseURL = properties["DP"] as? String
        self.databasePublisher = properties["DB"] as? String
    }
    
//    @NSManaged var abstract: String?
//    @NSManaged var acmid: String?
//    @NSManaged var address: String?
//    @NSManaged var author: String?
//    @NSManaged var booktitle: String?
//    @NSManaged var doi: String?
//    @NSManaged var inproceeding: String?
//    @NSManaged var isbn: String?
//    @NSManaged var keywords: String?
//    @NSManaged var last_modified: NSDate?
//    @NSManaged var location: String?
//    @NSManaged var numpages: String?
//    @NSManaged var pages: String?
//    @NSManaged var publisher: String?
//    @NSManaged var series: String?
//    @NSManaged var title: String?
//    @NSManaged var url: String?
//    @NSManaged var year: String?
//    @NSManaged var isLiked: NSNumber?
//    @NSManaged var isRead: NSNumber?
//    @NSManaged var parent: Session?
    
}