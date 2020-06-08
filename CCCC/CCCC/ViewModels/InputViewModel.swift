//
//  InputViewModel.swift
//  CCCC
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

import Combine
import Foundation

extension Converter {
    class UserInputViewModel: ObservableObject {
        
        private let currencyFormatter = LazyCurrencyFormatterCache()
        
        private let numberFormatter: NumberFormatter = {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.maximumFractionDigits = 2
            f.minimumFractionDigits = 0
            return f
        }()
        
        // MARK: State
        
        @Published var amountString: String
        @Published var selectedQuote: Model.Quote?
        
        // MARK: Init
        
        init(amountString: String = "", selectedQuote: Model.Quote? = nil) {
            self.amountString = amountString
            self.selectedQuote = selectedQuote
        }
        
        // MARK: Helper Functions
        
        var textBoxHint: String {
            guard let selectedQuote = self.selectedQuote else {
                return "Tap Currency Below"
            }
            return "Enter \(selectedQuote.code) Amount"
        }
        
        var selectedFlag: String {
            return self.selectedQuote?.flag ?? "🏳️"
        }
        
        var isAmountEntered: Bool {
            return self.amountString != ""
        }
        
        var isQuoteSelected: Bool {
            return self.selectedQuote != nil
        }
        
        func resetAmountEntered() {
            self.amountString = ""
        }
        
        func formattedAmount(for toQuote: Model.Quote) -> String? {
            guard
                let input = Double(self.amountString),
                let fromQuote = self.selectedQuote
            else { return nil }
            let fromAmount = input / fromQuote.rate
            let toAmount = fromAmount * toQuote.rate
            return self.currencyFormatter[toQuote.code].string(from: .init(value: toAmount))
        }
        
        func formattedRate(for toQuote: Model.Quote) -> String {
            guard let fromQuote = self.selectedQuote else { return "" }
            let fromRate = 1 / fromQuote.rate
            let toRate = fromRate * toQuote.rate
            return self.numberFormatter.string(from: .init(value: toRate))
                                       .map { $0 + ":1" } ?? ""
        }
    }
}

fileprivate class LazyCurrencyFormatterCache {
    private var formatters: [String: NumberFormatter] = [:]
    subscript(_ code: String) -> NumberFormatter {
        // Different currencies have different rules for
        // number of fraction digits and other formatting.
        // This may be overkill, but I'm lettinng NSNumberFormatter
        // decide what to do based on the currency being formatted
        if let formatter = self.formatters[code] { return formatter }
        let new = NumberFormatter()
        new.numberStyle = .currency
        new.currencyCode = code
        new.currencySymbol = ""
        self.formatters[code] = new
        return new
    }
}
