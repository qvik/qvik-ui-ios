// Copyright (c) 2015-2016 Qvik (www.qvik.fi)
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

import CoreMotion
import UIKit

import QvikSwift

/// Handles reading the accelerator sensor
private class MotionManager {
    fileprivate let updateInterval = 0.05

    /// Motion manager for retrieving accelerometer data
    fileprivate let motionManager = CMMotionManager()

    /// Listeners to the accelerometer values
    fileprivate var listeners = [ParallaxView]()

    // MARK: Private methods

    fileprivate func stopMotionManager() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    fileprivate func startMotionManager() {
        if motionManager.isDeviceMotionAvailable && !motionManager.isDeviceMotionActive {
            motionManager.deviceMotionUpdateInterval = updateInterval
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] deviceMotion, error in
                guard let deviceMotion = deviceMotion, let strongSelf = self else {
                    return
                }

                for listener in strongSelf.listeners {
                    listener.accelerometerGravityValue(x: CGFloat(deviceMotion.gravity.x), y: CGFloat(deviceMotion.gravity.y), update: true)
                }
            }
        }
    }

    // MARK: Public methods

    /// Adds a new accelerometer value listener
    func addListener(_ view: ParallaxView) {
        assert(Thread.isMainThread, "May only be called on the main thread")

        // Dont add if its there already
        if listeners.contains(view) {
            return
        }

        listeners.append(view)
//        log.debug("Added motion manager listener; now we have \(listeners.count) listeners")

        // Pull the latest sample and send it to the new listener as an initial value
        if let deviceMotion = motionManager.deviceMotion {
            view.accelerometerGravityValue(x: CGFloat(deviceMotion.gravity.x), y: CGFloat(deviceMotion.gravity.y), update: false)
        }

        startMotionManager()
    }

    /// Removes a new accelerometer value listener
    func removeListener(_ view: ParallaxView) {
        assert(Thread.isMainThread, "May only be called on the main thread")

        listeners = listeners.filter { $0 != view }
//        log.debug("Removed motion manager listener; now we have \(listeners.count) listeners")

        if listeners.isEmpty {
            stopMotionManager()
        }
    }

    deinit {
        stopMotionManager()
    }
}

/**
 Custom view that provides 'parallax scrolling' effect on it's content. The content can be any UIView, 
 obviously the usual use case would be to use an image.
 
 Use the ```parallaxScale``` and ```accelerometerMagnitude``` parameters to configure the magnitude of the effects.
 
 Example of using a custom content view:
 
 ```
 let imageView = CachedImageView(frame: frame)
 imageView.contentMode = .ScaleAspectFill
 imageView.imageUrl = imageUrl
 parallaxView.parallaxContentView = imageView
 parallaxView.parallaxScale = 1.1
 parallaxView.accelerometerMagnitude = 0.05
 parallaxView.parentScrollView = myOuterTableView
 ```
*/
open class ParallaxView: UIView {
    fileprivate static let motionManager = MotionManager()

    /// Scale for the content; must be larger than 1.0; eg. use 1.1 for parallax content to be 10% larger
    /// than the actual view. The larger the value, more drastic the effect. Default is 1.1.
    open var parallaxScale: CGFloat = 1.1 {
        didSet {
            assert(parallaxScale > 1.0)
            updateTransform()
        }
    }

    /// Magnitude of the accelerometer translating effect on content, relative to the view's size,
    /// eg. use "0.1" to provide a tilt translation of max 10%. Not set by default. Value range is [0, 1].
    ///
    /// By setting this to nil, the view stops receiving accelerometer data and can thus save battery life.
    open var accelerometerMagnitude: CGFloat? = nil {
        didSet {
            if let accelerometerMagnitude = accelerometerMagnitude {
                assert(accelerometerMagnitude >= 0)
                assert(accelerometerMagnitude <= 1.0)

                if window != nil {
                    ParallaxView.motionManager.addListener(self)
                }
            } else {
                ParallaxView.motionManager.removeListener(self)
            }
            updateTransform()
        }
    }

    /// Set this to use any custom view as content. Clears any existing content. Defaults to nil.
    /// If this is not set (nil), the first subview will be used as the parallax view. In this case, no
    /// constraints are set programmatically and they have to be set in the IB.
    open var parallaxContentView: UIView? {
        didSet {
            if let currentConstraints = currentConstraints {
                NSLayoutConstraint.deactivate(currentConstraints)
                self.currentConstraints = nil
            }

            if let oldValue = oldValue {
                oldValue.removeFromSuperview()
            }

            guard let parallaxContentView = parallaxContentView else {
                // Was set to nil, do nothing
                return
            }

            if subviews.contains(parallaxContentView) {
                // This is a view from IB or added as subview from code; do not manage constraints eg. properties here
                return
            }

            parallaxContentView.translatesAutoresizingMaskIntoConstraints = false

            addSubview(parallaxContentView)

            let leftConstraint = NSLayoutConstraint(item: parallaxContentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: parallaxContentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
            let topConstraint = NSLayoutConstraint(item: parallaxContentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: parallaxContentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)

            currentConstraints = [leftConstraint, rightConstraint, topConstraint, bottomConstraint]
            NSLayoutConstraint.activate(currentConstraints!)
        }
    }

    /// The scroll view to be used as the 'parent' ie. used for the parallax effect. If not set, the parent is 
    /// searched for automatically; this will be the nearest ancestral UICollectionView, UITableView or UIScrollView.
    /// Most often it is not required to set this.
    open var parentScrollView: UIScrollView? = nil {
        didSet {
            handleViewHierarchyChange()
        }
    }

    /// Relative (0..1) vertical position of this view on the scrollview
    fileprivate var relativeVerticalPosition: CGFloat = 0.5

    /// Relative (0..1) horizontal position of this view on the scrollview
    fileprivate var relativeHorizontalPosition: CGFloat = 0.5

    /// Layout constraints for the current content view
    fileprivate var currentConstraints: [NSLayoutConstraint]?

    /// Latest gravity x axis sample of accelerometer
    fileprivate var acceleratorGravityX: CGFloat = 0

    /// Latest gravity y axis sample of accelerometer
    fileprivate var acceleratorGravityY: CGFloat = 0

    /// Reference to the nearest ancestral scroll view, if any; if not part of a scrollview, this is nil
    fileprivate var scrollView: UIScrollView?

    // MARK: Private methods

    /// Enumerates through the view hierarchy from this view to its top level ancestor and 
    /// returns a view selected by the callback.
    fileprivate func enumerateViewHierarchy(_ callback: ((UIView) -> UIScrollView?)) -> UIScrollView? {
        var v = self.superview

        while v != nil {
            if let scrollView = callback(v!) {
                return scrollView
            }

            v = v?.superview
        }

        return nil
    }

    /// Returns the UIScrollView this view is part of, if any
    fileprivate func getScrollView() -> UIScrollView? {
        // If explicit parent view is set, use it
        if parentScrollView != nil {
            return parentScrollView
        }

        var firstScrollView: UIScrollView?

        // Look for the nearest UITableView of UIScrollView
        let tableOrCollectionView = enumerateViewHierarchy { (view: UIView) -> UIScrollView? in
            if let collectionView = view as? UICollectionView {
                return collectionView
            }
            if let tableView = view as? UITableView {
                return tableView
            }

            if let scrollView = view as? UIScrollView, firstScrollView == nil {
                firstScrollView = scrollView
            }

            return nil
        }

        if tableOrCollectionView != nil {
            return tableOrCollectionView
        } else {
            return firstScrollView
        }
    }

    /// Removes the key-value observer for the current scroll view, if any
    fileprivate func removeScrollViewObserver() {
        if let scrollView = scrollView {
            scrollView.removeObserver(self, forKeyPath: "contentOffset", context: nil)
            self.scrollView = nil
        }
    }

    /// Attempts to start listening to scroll events if attached to a scrollview
    fileprivate func handleViewHierarchyChange() {
        // If parallax content view is not set, use the first subview as one (if any) 
        if let firstSubview = subviews.first, parallaxContentView == nil {
            parallaxContentView = firstSubview
        }

        // End observing on the current scrollView as this may change
        removeScrollViewObserver()

        // Find the ancestor scrollView if one is available
        scrollView = getScrollView()

        if let scrollView = scrollView {
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)

            // Update initial transform
            updateScrollPosition()
        }
    }

    /// Updates the transform of the content view; this is calculated from multiple factors
    fileprivate func updateTransform() {
        guard let parallaxContentView = parallaxContentView else {
            return
        }

        let scale = CGAffineTransform(scaleX: parallaxScale, y: parallaxScale)

        // Translate the image by the relative horizontal position on the scrollview
        let extraHorizontalSpace = (parallaxScale - 1.0) * width
        var x: CGFloat = (-extraHorizontalSpace / 2) + (relativeHorizontalPosition * extraHorizontalSpace)

        // Translate the image by the relative vertical position on the scrollview
        let extraVerticalSpace = (parallaxScale - 1.0) * height
        var y: CGFloat = (-extraVerticalSpace / 2) + (relativeVerticalPosition * extraVerticalSpace)

        if let accelerometerMagnitude = accelerometerMagnitude {
            x += acceleratorGravityX * accelerometerMagnitude * width
            y += acceleratorGravityY * accelerometerMagnitude * height
        }

//        log.debug("transform:  x,y: \(x), \(y), view: \(unsafeAddressOf(self))")
//        log.debug("width: \(width), height: \(height), pos: \(relativeHorizontalPosition), \(relativeVerticalPosition)")
        let translate = CGAffineTransform(translationX: x, y: y)

        parallaxContentView.transform = scale.concatenating(translate)
    }

    /// Updates the parallax effect based on the scroll view position
    fileprivate func updateScrollPosition() {
        guard let scrollView = scrollView, window != nil else {
            // If the view is not part of a window / view hierarchy under a scrollview, do nothing
            return
        }

        // Figure out my frame on the scrollview
        var myFrame = superview!.convert(frame, to: scrollView)

        if let collectionView = scrollView as? UICollectionView,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, layout.scrollDirection == .horizontal {
                // Horizontal scrolling within a collection view
                myFrame.origin.x -= collectionView.contentOffset.x
                let rangeWidth = collectionView.width + myFrame.width
                let positionOnRange = myFrame.minX + myFrame.width

                relativeHorizontalPosition = 1.0 - max(0.0, min(1.0, (positionOnRange / rangeWidth)))
                relativeVerticalPosition = 0.5
        } else {
            // Vertical scrolling
//            log.debug("scrollView.contentOffset = \(scrollView.contentOffset), myFrame = \(myFrame), scrollView.frame = \(scrollView.frame)")
            myFrame.origin.y -= scrollView.contentOffset.y
            let rangeHeight = scrollView.height + myFrame.height
            let positionOnRange = myFrame.minY + myFrame.height

            relativeHorizontalPosition = 0.5
            relativeVerticalPosition = 1.0 - max(0.0, min(1.0, (positionOnRange / rangeHeight)))
        }

        updateTransform()
    }

    fileprivate func commonInit() {
        clipsToBounds = true
    }

    private var kvoToken: NSKeyValueObservation?

    // MARK: From NSKeyValueObserving

    // Block-based KVO is a iOS 10+ feature
    // swiftlint:disable block_based_kvo
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        updateScrollPosition()
    }

    // MARK: From UIView

    override open func didMoveToWindow() {
        if window != nil {
            // Moved to view hierarchy; re-enable accelerometer listening if is it enabled
            if accelerometerMagnitude != nil {
                ParallaxView.motionManager.addListener(self)
            }
        } else {
            // Moved out of view hierarchy; disable accelerometer listening
            ParallaxView.motionManager.removeListener(self)
        }

        handleViewHierarchyChange()
    }

    override open func didMoveToSuperview() {
        handleViewHierarchyChange()
    }

    // MARK: 'Internal' methods

    func accelerometerGravityValue(x: CGFloat, y: CGFloat, update: Bool) {
        acceleratorGravityX = x
        acceleratorGravityY = y

        if update {
            updateTransform()
        }
    }

    // MARK: Lifecycle etc

    override open func layoutSubviews() {
        super.layoutSubviews()

        updateScrollPosition()
    }

    deinit {
        removeScrollViewObserver()

        ParallaxView.motionManager.removeListener(self)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }
}
