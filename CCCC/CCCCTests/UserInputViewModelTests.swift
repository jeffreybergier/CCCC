//
//  UserInputViewModelTests.swift
//  CCCCTests
//
//  Created by Jeffrey Bergier on 2020/06/08.
//  Copyright © 2020 Jeffrey Bergier.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
@testable import CCCC

class UserInputViewModelTests: XCTestCase {

    func test_textBoxHint() {
        let vm = Converter.UserInputViewModel()
        XCTAssertEqual(vm.textBoxHint, "Tap Currency Below")
        vm.selectedQuote = SWIFT_PREVIEWS_quote1
        XCTAssertEqual(vm.textBoxHint, "Enter USD Amount")
        vm.selectedQuote = SWIFT_PREVIEWS_quote2
        XCTAssertEqual(vm.textBoxHint, "Enter GBP Amount")
    }
    
    func test_selectedFlag() {
        let vm = Converter.UserInputViewModel()
        XCTAssertEqual(vm.selectedFlag, "🏳️")
        vm.selectedQuote = SWIFT_PREVIEWS_quote1
        XCTAssertEqual(vm.selectedFlag, "🇺🇸")
        vm.selectedQuote = SWIFT_PREVIEWS_quote2
         XCTAssertEqual(vm.selectedFlag, "🇬🇧")
    }
    
    func test_isAmountEntered() {
        let vm = Converter.UserInputViewModel()
        XCTAssertFalse(vm.isAmountEntered)
        vm.amountString = "A"
        XCTAssertTrue(vm.isAmountEntered)
    }
    
    func test_isQuoteSelected() {
        let vm = Converter.UserInputViewModel()
        XCTAssertFalse(vm.isQuoteSelected)
        vm.selectedQuote = SWIFT_PREVIEWS_quote1
        XCTAssertTrue(vm.isQuoteSelected)
    }
    
    func test_resetAmountEntered() {
        let vm = Converter.UserInputViewModel()
        XCTAssertFalse(vm.isAmountEntered)
        vm.amountString = "A"
        XCTAssertTrue(vm.isAmountEntered)
        vm.resetAmountEntered()
        XCTAssertFalse(vm.isAmountEntered)
    }
    
    func test_formattedAmount() {
        let vm = Converter.UserInputViewModel()
        XCTAssertNil(vm.formattedAmount(for: SWIFT_PREVIEWS_quote1))
        vm.amountString = "ABC"
        vm.selectedQuote = SWIFT_PREVIEWS_quote2 // converting from GBP
        XCTAssertNil(vm.formattedAmount(for: SWIFT_PREVIEWS_quote1))
        vm.amountString = "100" // to 100 USD
        XCTAssertEqual(vm.formattedAmount(for: SWIFT_PREVIEWS_quote1), "126.94")
    }
    
    func test_formattedRate() {
        let vm = Converter.UserInputViewModel()
        XCTAssertEqual(vm.formattedRate(for: SWIFT_PREVIEWS_quote1), "")
        vm.selectedQuote = SWIFT_PREVIEWS_quote2
        XCTAssertEqual(vm.formattedRate(for: SWIFT_PREVIEWS_quote1), "1.27:1")
    }
    
}
