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

struct CurrencyEntry: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        HStack {
            Text("🇺🇸").font(.largeTitle)
            TextField("Enter USD", text: self.$viewModel.userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .font(.title)
            Button(action: { self.viewModel.userInput = "" }, label: { Text("✖️") })
        }
    }
}

extension CurrencyEntry {
    class ViewModel: ObservableObject {

        @Published var userInput: String

        private let formatter: NumberFormatter = {
            let f = NumberFormatter()
            f.numberStyle = .currency
            f.currencySymbol = ""
            return f
        }()

        init(userInput: String = "") {
            self.userInput = userInput
        }

        func formattedPrice(withRate rate: Double) -> String? {
            guard let input = Double(self.userInput) else { return nil }
            return self.formatter.string(from: .init(value: input * rate))
        }
    }
}

struct CurrencyEntry_Previews1: PreviewProvider {
    static var previews: some View {
        CurrencyEntry(viewModel: .init(userInput: "100000"))
    }
}

struct CurrencyEntry_Previews2: PreviewProvider {
    static var previews: some View {
        CurrencyEntry(viewModel: .init(userInput: ""))
    }
}
