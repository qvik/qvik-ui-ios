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
import QvikSwift

/**
 A UILabel subclass that will size itself correctly when given an
 attributed string with lineHeightMultiple < 1.
 
 Paragraph style with the line height parameter is read from the
 attributed string at location 0. The adjustment size is calculated
 based on the font used, which is read from the attributed string
 attributes at location 0, or if that is nil, from UILabel.font.
 */
open class LineHeightAwareLabel: UILabel {
    private var heightDiff: CGFloat?
    
    override open var intrinsicContentSize: CGSize {
        if let diff = heightDiff {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width, height: size.height + diff)
        } else {
            return super.intrinsicContentSize
        }
    }
    
    override open func drawText(in rect: CGRect) {
        if let diff = heightDiff {
            super.drawText(in: rect.applying(CGAffineTransform(translationX: 0, y: diff/2)).insetBy(dx: 0, dy: -diff/2))
        } else {
            super.drawText(in: rect)
        }
    }
    
    override open var attributedText: NSAttributedString? {
        didSet {
            if let attributedText = attributedText,
                let lineHeightMultiple = (attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)?.lineHeightMultiple,
                let font = attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont ?? self.font,
                lineHeightMultiple < 1 {
                
                let baseHeight = ceil(attributedText.string.boundingRectWithFont(font).height)
                let lines = round(baseHeight/font.lineHeight)
                // TODO add NSAttributedString.boundingRect() shorthand to QvikSwift
                let diff = ceil(baseHeight - attributedText.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height)
                heightDiff = diff / lines
            }
        }
    }
}
