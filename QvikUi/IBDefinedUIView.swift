// Copyright (c) 2016 Qvik (www.qvik.fi)
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
 A UIView subclass that when further subclassed, allows defining the custom
 view's contents with Interface Builder, using @IBOutlets, and having those
 definitions automatically loaded.
 
 To use this, create a class that subclasses this one, and a xib file with
 the same name containing a single top level UIView object and the
 corresponding class set as the File's Owner (NOT as the custom class for
 the UIView).
 
 To load a xib file with a different name, which you will need to do when
 further subclassing, set the variable nibName to override the default
 behaviour.
 */
open class IBDefinedUIView: UIView {
    
    fileprivate var view: UIView!
    
    var nibName: String?
    
    fileprivate func loadViewFromNib(_ name: String) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: name, bundle: bundle)
        
        // Assumes UIView is top level and only object in the CustomView.xib file
        view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        addSubview(view)
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName ?? String(describing: type(of: self)))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib(nibName ?? String(describing: type(of: self)))
    }
    
}
