//
//  VerticalCenteredTextView.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/25/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Foundation
import UIKit

class VerticalCenteredTextView: UITextView {
    

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.addContentSizeObserver()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addContentSizeObserver()
    }
    
    private func addContentSizeObserver() {
        self.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    private func removeContentSizeObserver() {
        self.removeObserver(self, forKeyPath: "contentSize")
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        //let textView = object as! UITextView
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.contentInset.top = topCorrect
    }
    
    deinit {
        removeContentSizeObserver()
    }
    
}
