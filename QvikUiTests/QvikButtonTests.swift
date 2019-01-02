// The MIT License (MIT)
//
// Copyright (c) 2015 Qvik (www.qvik.fi)
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

class QvikButtonTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBackgroundColor() {
        let clear = UIColor.clear
        let blue = UIColor.blue
        let red = UIColor.red
        let green = UIColor.green

        // Test setting .Normal state (current) bg color
        let button1 = QvikButton(type: .system)
        button1.setBackgroundColor(blue, forControlState: UIControl.State())
        XCTAssert(button1.state == UIControl.State())
        XCTAssert(button1.backgroundColor == blue)

        // Test .Normal feedback in case of missing state color
        let button2 = QvikButton(type: .system)
        button2.setBackgroundColor(blue, forControlState: UIControl.State())
        button2.isSelected = true
        XCTAssert(button2.backgroundColor == blue)

        // Test that bg color changes when state changes
        let button3 = QvikButton(type: .system)
        button3.setBackgroundColor(clear, forControlState: UIControl.State())
        button3.setBackgroundColor(blue, forControlState: .disabled)
        button3.setBackgroundColor(red, forControlState: .highlighted)
        button3.setBackgroundColor(green, forControlState: .selected)
        button3.isEnabled = false
        XCTAssert(button3.backgroundColor == blue)
        button3.isEnabled = true
        XCTAssert(button3.backgroundColor == clear)
        button3.isHighlighted = true
        XCTAssert(button3.backgroundColor == red)
        button3.isHighlighted = false
        button3.isSelected = true
        XCTAssert(button3.backgroundColor == green)
    }
}
