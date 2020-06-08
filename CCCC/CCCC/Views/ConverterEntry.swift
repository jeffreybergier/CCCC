//
//  CurrencyEntry.swift
//  CCCC
//
//  Created by Jeffrey Bergier on 2020/06/06.
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

import SwiftUI

extension Converter {
    struct Entry: View {
        
        @ObservedObject var userInput: UserInputViewModel
        
        // Hack that allows for keyboard dismissal in SwiftUI
        // Maybe this can be removed in the future
        @State private var keyboardPresented: Bool = false
        
        var body: some View {
            HStack {
                Text(self.userInput.selectedFlag).font(.largeTitle)
                TextField(self.userInput.textBoxHint, text: self.$userInput.amountString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .font(.body)
                    .multilineTextAlignment(self.userInput.isAmountEntered ? .leading : .center)
                    .onTapGesture { withAnimation { self.keyboardPresented = true } }
                Button(action: {
                    guard self.keyboardPresented == false else {
                        withAnimation { self.keyboardPresented = false }
                        UIApplication.shared.endEditing()
                        return
                    }
                    // First delete the amount
                    // If the amount is already deleted then clear
                    // the selected Quote
                    if self.userInput.isAmountEntered {
                        self.userInput.resetAmountEntered()
                    } else {
                        self.userInput.selectedQuote = nil
                    }
                }, label: {
                    Text(self.keyboardPresented ? "Done" : "✖️")
                        .font(.headline)
                })
            }
            .disabled(!self.userInput.isQuoteSelected)
        }
    }
}

struct Entry_Preview1: PreviewProvider {
    static var previews: some View {
        Converter.Entry(userInput: .init())
    }
}

struct Entry_Preview2: PreviewProvider {
    static var previews: some View {
        Converter.Entry(userInput: .init(selectedQuote: SWIFT_PREVIEWS_quote1))
    }
}

struct Entry_Preview3: PreviewProvider {
    static var previews: some View {
        Converter.Entry(userInput: .init(amountString: "100000",
                                         selectedQuote: SWIFT_PREVIEWS_quote2))
    }
}
