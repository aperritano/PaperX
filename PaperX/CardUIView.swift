//
//  CardUIView.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/20/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import UIKit
import Material
import CoreData

class CardUIView: UIView {
    
    @IBOutlet weak var sourceTitleTextView: UITextView!
    @IBOutlet weak var paperTitleTextView: UITextView!

    @IBOutlet weak var abstractTextView: UITextView!
    @IBOutlet weak var authorsTextView: UITextView!
    
    var paperEntry : PaperEntry?
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
         self.layer.cornerRadius = 5;
        self.layer.masksToBounds = false;
        
        self.layer.shadowColor = MaterialColor.grey.darken4.CGColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 5
        print("bounds \(self.bounds)")
        print("frame \(self.frame)")
        print("rect \(rect)")
       
        self.layer.shadowPath = UIBezierPath(rect: rect).CGPath
        
        // Drawing code
    }
 

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
        abstractTextView = UITextView()
    }
    
    func populateCard(entry: PaperEntry) {
         paperEntry = entry
        
        let authors = paperEntry!.valueForKey("authors") as! [String]
        let newString = authors.joinWithSeparator(",").stringByDecodingHTMLEntities

       
        
        self.populateCard(paperEntry!.inproceeding, paperTitle: paperEntry!.title, abstract: paperEntry!.abstract, authors: newString)
    }
    
    func populateCard(sourceTitle:String?, paperTitle: String?, abstract: String?, authors: String) {
        
        if let s = sourceTitle {
            sourceTitleTextView.text = s
        }
        if let p = paperTitle {
            paperTitleTextView.text = p
        }
        if let a = abstract  {
            abstractTextView.text = a
        }
        
            authorsTextView.text = authors
        
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
