// The MIT License (MIT)
//
// Copyright (c) 2015-2018 Qvik (www.qvik.fi)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

/**
 An NSLayoutConstraint subclass that automatically resizes itself in
 response to keyboard frame change events. The animation is executed by
 calling superview.layoutIfNeeded() for the first item.
 
 The initialisation is done in awakeFromNib(), so if the constraint is
 created programmatically rather than through setting the constraint's
 class in interface builder, that will need to be called manually.
 */
open class KeyboardConstraint: NSLayoutConstraint {
    /// Disables all custom behaviour
    open var disableChanges = false
    /// The value the constraint constant gets set to, adding keyboard height or not
    open var originalConstant: CGFloat!

    @objc
    private func keyboardNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo, !disableChanges {
            guard let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let view = (firstItem as? UIView) ?? (secondItem as? UIView) else {
                return
            }

            view.superview?.layoutIfNeeded()

            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.4

            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]
            let animationCurveRaw = (animationCurveRawNSN as? UInt) ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

            if endFrame.y < UIScreen.main.bounds.size.height {
                constant = endFrame.height + originalConstant
            } else {
                constant = originalConstant
            }

            UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
                view.superview?.layoutIfNeeded()
            }, completion: nil)
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        originalConstant = constant
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
