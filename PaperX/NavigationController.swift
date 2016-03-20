//
//  NavigationController.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/19/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Foundation
import UIKit
import Material

class NavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Status bar white font
        self.navigationBar.barStyle = UIBarStyle.Black
        self.navigationBar.barTintColor = MaterialColor.red.base
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

    }
}