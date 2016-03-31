//
//  CustomKolodaView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

let defaultBottomOffset:CGFloat = 0
let defaultTopOffset:CGFloat = 15
let defaultHorizontalOffset:CGFloat = 10
let defaultHeightRatio:CGFloat = 1.50
let backgroundCardHorizontalMarginMultiplier:CGFloat = 0.05
let backgroundCardScalePercent:CGFloat = 1.5

class CustomKolodaView: KolodaView {
    
//    override func frameForCardAtIndex(index: UInt) -> CGRect {
//        if index == 0 {
//            print("frame \(index)")
//            let topOffset:CGFloat = defaultTopOffset
//            let xOffset:CGFloat = defaultHorizontalOffset
//            let width = CGRectGetWidth(self.frame ) - 2 * defaultHorizontalOffset
//            let height = width * defaultHeightRatio
//            let yOffset:CGFloat = topOffset
//            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
//            print("index 0 frame \(frame)")
//            return frame
//        } else if index == 1 {
//            print("frame \(index)")
//            let topOffset:CGFloat = defaultTopOffset
//            let xOffset:CGFloat = -self.bounds.width * backgroundCardHorizontalMarginMultiplier
//            let width = CGRectGetWidth(self.frame ) - 2 * defaultHorizontalOffset
//            let height = width * defaultHeightRatio
//            let yOffset:CGFloat = topOffset
//            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
//            print("index 0 frame \(frame)")
//        }
//        return CGRectZero
//    }
    
    override func frameForCardAtIndex(index: UInt) -> CGRect {        
        if index == 0 {
            let topOffset:CGFloat = defaultTopOffset
            let xOffset:CGFloat = defaultHorizontalOffset
            let width = CGRectGetWidth(self.frame ) - 2 * defaultHorizontalOffset
            let height = width * defaultHeightRatio
            let yOffset:CGFloat = topOffset
            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            return frame
        } else if index == 1 {
            let horizontalMargin = -self.bounds.width * backgroundCardHorizontalMarginMultiplier
            let width = self.bounds.width
            let height = width * defaultHeightRatio
            return CGRect(x: horizontalMargin, y: defaultTopOffset-5, width: width, height: height)
        }
        return CGRectZero
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        LOG.debug("began")
        updateViewForTouch(touches.first!)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        LOG.debug("moved")
        updateViewForTouch(touches.first!)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        LOG.debug("ended")
        layer.transform = CATransform3DIdentity
    }
    
    private func updateViewForTouch(touch: UITouch) {
        LOG.debug("update")
        let forcePercentage = touch.maximumPossibleForce > 0 ? touch.force / touch.maximumPossibleForce : 0.5
        let forceWeight = 0.3 + (0.7 * forcePercentage)
        
        let touchLocation = touch.locationInView(self)
        
        let halfWidth = (bounds.width / 2)
        let halfHeight = (bounds.height / 2)
        
        let locationFromCenter = CGPointMake(touchLocation.x - halfWidth, touchLocation.y - halfHeight)
        
        let x = (0.0002 * forceWeight * locationFromCenter.x / halfWidth)
        let y = (0.0002 * forceWeight * locationFromCenter.y / halfHeight)
        
        layer.transform = transform3DPerspective(x, y: y)
    }
    
    func transform3DPerspective(x: CGFloat, y: CGFloat) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m14 = x
        transform.m24 = y
        return transform
    }


}
