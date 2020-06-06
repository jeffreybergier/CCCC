//
//  CurrencyTable.swift
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

struct CurrencyTable: View {
    let data: [CurrencyModel.Quote]
    let userInput: String
    private var inputDoubleValue: Double? {
        Double(self.userInput.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    var body: some View {
        List(self.data) { quote in
            ViewSwitch(quote: quote, price: self.inputDoubleValue)
        }
    }
}

fileprivate struct ViewSwitch: View {
    let quote: CurrencyModel.Quote
    let price: Double?
    private func priceString(to: Double, from: Double) -> String {
        formatter.string(from: .init(value: to * from))!
    }
    private func rateString(_ rate: Double) -> String {
        "1:" + formatter.string(from: .init(value: rate))!
    }
    var body: some View {
        if let price = self.price {
            return AnyView(
                WithPriceCell(flag: quote.toFlag,
                              code: quote.to,
                              price: self.priceString(to: price, from: quote.value),
                              rate: self.rateString(quote.value))
            )
        } else {
            return AnyView(
                WithOutPriceCell(flag: quote.toFlag,
                                 code: quote.to,
                                 rate: self.rateString(quote.value))
            )
        }
    }
}

fileprivate struct WithPriceCell: View {
    let flag: String
    let code: String
    let price: String
    let rate: String
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(self.flag).font(.largeTitle)
            Text(self.price).font(Font.title.monospacedDigit())
            Text(self.code).font(.headline)
            Spacer()
            Text(self.rate).font(Font.subheadline.monospacedDigit())
        }
    }
}

fileprivate struct WithOutPriceCell: View {
    let flag: String
    let code: String
    let rate: String
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(self.flag).font(.largeTitle)
            Text(self.code).font(.title)
            Spacer()
            Text(self.rate).font(Font.subheadline.monospacedDigit())
        }
    }
}

extension CurrencyModel.Quote: Identifiable {
    var id: String {
        _key
    }
}

struct CurrencyTable_Preview1: PreviewProvider {
    static var previews: some View {
        let data: [CurrencyModel.Quote] = TESTING_model.quotes
        return CurrencyTable(data: data, userInput: "10.0")
    }
}

struct CurrencyTable_Preview2: PreviewProvider {
    static var previews: some View {
        let data: [CurrencyModel.Quote] = TESTING_model.quotes
        return CurrencyTable(data: data, userInput: "笑う")
    }
}

struct CurrencyTable_Preview3: PreviewProvider {
    static var previews: some View {
        let data: [CurrencyModel.Quote] = TESTING_model.quotes
        return CurrencyTable(data: data, userInput: "1000000000.0")
    }
}

// Number formatters are expensive to create
// or change, so I'm keeping this one as a
// fileprivate constant for performance.
fileprivate let formatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencySymbol = ""
    return f
}()
