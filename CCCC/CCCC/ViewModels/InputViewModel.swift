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
        
        private let formatter: NumberFormatter = {
            let f = NumberFormatter()
            f.numberStyle = .currency
            f.currencySymbol = ""
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
        
        func formattedAmount(for quote: Model.Quote) -> String? {
            guard
                let input = Double(self.amountString),
                let selectedQuote = self.selectedQuote
            else { return nil }
            let usdAmount = input / selectedQuote.rate
            let newRateAmount = usdAmount * quote.rate
            return self.formatter.string(from: .init(value: newRateAmount))
        }
        
        func formattedRate(for quote: Model.Quote) -> String {
            guard let selectedQuote = self.selectedQuote else { return "" }
            let baseRate = 1 / selectedQuote.rate
            let newRate = baseRate * quote.rate
            return self.formatter.string(from: .init(value: newRate))
                                 .map { $0 + ":1" } ?? ""
        }
    }
}
