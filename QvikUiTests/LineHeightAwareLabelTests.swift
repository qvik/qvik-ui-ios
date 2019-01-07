// The MIT License (MIT)
//
// Copyright (c) 2018 Qvik (www.qvik.fi)
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
import XCTest

import QvikUi

class LineHeightAwareLabelTests: XCTestCase {

    var uiLabel = UILabel()
    var lhaLabel = LineHeightAwareLabel()

    let font = UIFont.systemFont(ofSize: 20)
    let paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 0.5
        return style
    }()

    override func setUp() {
        super.setUp()

        uiLabel.font = font
        for label in [uiLabel, lhaLabel] {
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /*
     Empty content should not crash.
     */
    func testEmptyLabels() {
        lhaLabel.attributedText = nil
        lhaLabel.attributedText = NSAttributedString(string: "")
    }

    /*
     A single line label with lineHeightMultiple < 1 should retain its
     original height.
     */
    func testSimpleLabel() {
        let string = "Label"
        uiLabel.text = string
        lhaLabel.attributedText = NSAttributedString(string: string, attributes: [.font: font, .paragraphStyle: paragraphStyle])

        XCTAssert(abs(uiLabel.intrinsicContentSize.height - lhaLabel.intrinsicContentSize.height) <= 1)
    }

    /*
     A multiline label with lineHeightMultiple < 1 should retain its
     original height for the first row, and have a reduced height for
     the rest, resulting in a label height of 1 + 0.5 in case of
     lineHeightMultiple = 0.5, or 1.5 / 2 times the height of regular
     UILabel.
     */
    func testMultilineLabel() {
        let string = "Label\nLabel"
        uiLabel.text = string
        lhaLabel.attributedText = NSAttributedString(string: string, attributes: [.font: font, .paragraphStyle: paragraphStyle])

        XCTAssert(abs(0.75 * uiLabel.intrinsicContentSize.height - lhaLabel.intrinsicContentSize.height) <= 1)
    }

    /*
     As above, except with line breaks due to constraints instead of
     explicit line breaks in text.
     */
    func testLabelWithLineBreaks() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        let string = "Label Label"
        uiLabel.text = string
        lhaLabel.attributedText = NSAttributedString(string: string, attributes: [.font: font, .paragraphStyle: paragraphStyle])

        view.addSubview(uiLabel)
        view.addSubview(lhaLabel)
        let constraints = [
            NSLayoutConstraint(item: view, toItem: uiLabel, attribute: .top),
            NSLayoutConstraint(item: view, toItem: uiLabel, attribute: .leading),
            NSLayoutConstraint(item: view, toItem: lhaLabel, attribute: .top),
            NSLayoutConstraint(item: view, toItem: lhaLabel, attribute: .leading),
            NSLayoutConstraint(item: uiLabel, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70),
            NSLayoutConstraint(item: uiLabel, toItem: lhaLabel, attribute: .width)
        ]
        NSLayoutConstraint.activate(constraints)

        view.layoutIfNeeded()

        XCTAssert(uiLabel.height > 0)
        XCTAssert(abs(0.75 * uiLabel.height - lhaLabel.height) <= 1)

        NSLayoutConstraint.deactivate(constraints)
    }
}
