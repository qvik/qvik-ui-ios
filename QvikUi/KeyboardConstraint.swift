//
//  KeyboardConstraint.swift
//  QvikUi
//
//  Created by Kosti Jokinen on 08/05/2018.
//  Copyright © 2018 Qvik. All rights reserved.
//

import UIKit

/**
 An NSLayoutConstraint subclass that automatically resizes itself in
 response to keyboard frame change events. The animation is done by calling
 superview.layoutIfNeeded() for the first item.
 
 The initialisation is done in awakeFromNib(), so if the constraint is
 created programmatically rather than through setting the constraint's class
 in interface builder, that will need to be called manually.
 */
class KeyboardConstraint: NSLayoutConstraint {
    
    var originalConstant: CGFloat!
    var disableChanges = false
    
    @objc func keyboardNotification(_ notification: Notification) -> Void {
        if let userInfo = notification.userInfo, !disableChanges {
            guard let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect, let view = (firstItem as? UIView) ?? (secondItem as? UIView) else {
                return
            }
            
            view.superview?.layoutIfNeeded()
            
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.4
            
            // keyboard animation info, use this to match buttons movement to the keyboard
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey]
            let animationCurveRaw = (animationCurveRawNSN as? UInt) ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if endFrame.y < UIScreen.main.bounds.size.height {
                // keyboard up, move button to match
                constant = endFrame.height + originalConstant
            } else {
                // keyboard down, move button to bottom
                constant = originalConstant
            }
            
            UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
                view.superview?.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        originalConstant = constant
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
}
