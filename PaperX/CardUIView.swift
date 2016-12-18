//
//  CardUIView.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/20/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import UIKit
import CoreData

class CardUIView: UIView {
    
    @IBOutlet weak var sourceTitleTextView: VerticalTextView!
    @IBOutlet weak var paperTitleTextView: VerticalTextView!

    @IBOutlet weak var abstractTextView: VerticalTextView!
    @IBOutlet weak var authorsTextView: VerticalTextView!
    
    
    var shadowAdded: Bool = false
    
    
    var paperEntry : PaperEntry?


    override func drawRect(rect: CGRect) {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.grayColor().CGColor
    }


//    override func drawRect(rect: CGRect) {
//        print("draw rect")
////        if shadowAdded {
////            print("returning \(shadowAdded)")
////            return
////        }
////        shadowAdded = true
//        print("shadown \(shadowAdded)")
//
//        print("card rect \(rect) bounds \(self.bounds) frame \(self.frame)")
//
//        let shadowLayer = UIView(frame: self.frame)
//        //shadowLayer.backgroundColor = UIColor.redColor()
//        shadowLayer.layer.shadowColor = UIColor.darkGrayColor().CGColor
//        shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius).CGPath
//        shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 0)
//        shadowLayer.layer.shadowOpacity = 0.6
//        shadowLayer.layer.shadowRadius = 1.5
//        shadowLayer.layer.masksToBounds = true
//        shadowLayer.clipsToBounds = false
//
//        self.superview?.addSubview(shadowLayer)
//        self.superview?.bringSubviewToFront(self)
//    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    override func drawRect(rect: CGRect) {
//         self.layer.cornerRadius = 5;
//        self.layer.masksToBounds = false;
//        
//        self.layer.shadowColor = MaterialColor.grey.darken4.CGColor
//        self.layer.shadowOpacity = 1
//        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.layer.shadowRadius = 5
//        print("bounds \(self.bounds)")
//        print("frame \(self.frame)")
//        print("rect \(rect)")
//       
//        self.layer.shadowPath = UIBezierPath(rect: rect).CGPath
//        
//        // Drawing code
//    }
 

    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        let nib:NSArray = NSBundle.mainBundle().loadNibNamed("CardUIView", owner: self, options: nil)
        configure()
    }
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
       configure()
    }
    
    func configure() {
   

//        self.layer.shouldRasterize = true
        abstractTextView = VerticalTextView()
    }
    
    func populateCard(entry: PaperEntry) {
         paperEntry = entry
        
        let authors = paperEntry!.valueForKey("authors") as! [String]
        let joinedAuthors = authors.joinWithSeparator("-").stringByDecodingHTMLEntities

       
        
        self.populateCard(paperEntry!.inproceeding, paperTitle: paperEntry!.title, abstract: paperEntry!.abstract, authors: joinedAuthors)
    }
    
    func populateCard(sourceTitle:String?, paperTitle: String?, abstract: String?, authors: String) {
        
        if let s = sourceTitle {
            sourceTitleTextView.selectable = false
            sourceTitleTextView.text = s.stringByReplacingOccurrencesOfString("\r", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil).uppercaseString
        }
        if let p = paperTitle {
            paperTitleTextView.selectable = false
            paperTitleTextView.text = p.stringByReplacingOccurrencesOfString("\r", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil).capitalizedString
        }
        if let a = abstract  {
            abstractTextView.selectable = false
            abstractTextView.text = a.stringByReplacingOccurrencesOfString("\r", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)

        }
        
        if !authors.isEmpty {
            authorsTextView.selectable = false
            authorsTextView.text = authors.capitalizedString
        }
        
        
    }
    
    func isLiked(liked:Bool) {
        paperEntry?.isLiked = liked
        self.saveEntityChanges()
    }
    
    func saveEntityChanges() {
        let entity = paperEntry as! NSManagedObject
        
        
        
        do {
            try entity.managedObjectContext?.save()
        } catch {
            let saveError = error as! NSError
            print(saveError)
        }
    }

}
