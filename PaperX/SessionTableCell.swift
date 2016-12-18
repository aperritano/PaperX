//
//  SessionCell.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/19/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Foundation
import UIKit
import Material

class SessionTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
  

    
    override func awakeFromNib() {
       
        super.awakeFromNib()
       // self.prepareView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func prepareView() {
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = MaterialColor.grey.lighten4.CGColor
        self.layer.masksToBounds = true
    }
    
    func promoteProfileView() {
//        UIApplication.sharedApplication().keyWindow!.bringSubviewToFront(self)
//        UIApplication.sharedApplication().keyWindow!.bringSubviewToFront(self.percentView)
    }
}