//
//  CardUIView.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/20/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Foundation
import UIKit
import Koloda
import Material

class CardUIView2: UIView {
    
    @IBOutlet weak var mainCardView: CardView!
    
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
        
        // Title label.
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "Welcome Back!"
        titleLabel.textColor = MaterialColor.blue.darken1
        titleLabel.font = RobotoFont.mediumWithSize(20)
        mainCardView.titleLabel = titleLabel
        
        // Detail label.
        let detailLabel: UILabel = UILabel()
        detailLabel.text = "It’s been a while, have you read any new books lately?"
        detailLabel.numberOfLines = 0
        mainCardView.detailView = detailLabel
        
        // Yes button.
        let btn1: FlatButton = FlatButton()
        btn1.pulseColor = MaterialColor.blue.lighten1
        btn1.pulseScale = false
        btn1.setTitle("YES", forState: .Normal)
        btn1.setTitleColor(MaterialColor.blue.darken1, forState: .Normal)
        
        // No button.
        let btn2: FlatButton = FlatButton()
        btn2.pulseColor = MaterialColor.blue.lighten1
        btn2.pulseScale = false
        btn2.setTitle("NO", forState: .Normal)
        btn2.setTitleColor(MaterialColor.blue.darken1, forState: .Normal)
        
        // Add buttons to left side.
        mainCardView.leftButtons = [btn1, btn2]
        
        // To support orientation changes, use MaterialLayout.
        self.addSubview(mainCardView)
        mainCardView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.alignFromTop(self, child: mainCardView, top: 100)
        MaterialLayout.alignToParentHorizontally(self, child: mainCardView, left: 20, right: 20)
    }

}