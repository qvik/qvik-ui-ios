//
//  LineHeightAwareLabel.swift
//  QvikUi
//
//  Created by Kosti Jokinen on 08/05/2018.
//  Copyright © 2018 Qvik. All rights reserved.
//

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
class LineHeightAwareLabel: UILabel {
    var heightDiff: CGFloat?
    
    override var intrinsicContentSize: CGSize {
        if let diff = heightDiff {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width, height: size.height + diff)
        } else {
            return super.intrinsicContentSize
        }
    }
    
    override func drawText(in rect: CGRect) {
        if let diff = heightDiff {
            super.drawText(in: rect.applying(CGAffineTransform(translationX: 0, y: diff/2)).insetBy(dx: 0, dy: -diff/2))
        } else {
            super.drawText(in: rect)
        }
    }
    
    override var attributedText: NSAttributedString? {
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
