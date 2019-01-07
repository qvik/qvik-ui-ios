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
 A UILabel subclass that will size itself sensibly when given an
 attributed string with lineHeightMultiple < 1.
 
 The magnitude of the label height correction is calculated in
 attributedText.didSet based on the font and lineHeightMultiple
 parameters, and otherwise persists. Paragraph style is read from
 the attributed string at location 0 and assumed to be constant,
 UILabel.font property is read as a fallback if paragraph style
 does not include a font value.
 
 A paragraph style object cannot be read from an empty string,
 so labels that are initialised empty should use, for example,
 " " instead to have their heights set correctly.
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
            super.drawText(in: rect.applying(CGAffineTransform(translationX: 0, y: diff / 2)).insetBy(dx: 0, dy: -diff / 2))
        } else {
            super.drawText(in: rect)
        }
    }

    override open var attributedText: NSAttributedString? {
        didSet {
            guard let attributedText = attributedText,
                attributedText.length > 0,
                let lineHeightMultiple = (attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)?.lineHeightMultiple,
                let font = attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont ?? self.font,
                lineHeightMultiple < 1 else {
                    return
            }
            let baseHeight = ceil(attributedText.string.boundingRect(font: font).height)
            let lines = round(baseHeight / font.lineHeight)

            let boundingRect = attributedText.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            let diff = ceil(baseHeight - boundingRect.height)
            heightDiff = diff / lines
        }
    }
}
