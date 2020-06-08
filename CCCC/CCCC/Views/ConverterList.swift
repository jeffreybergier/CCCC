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

extension Converter {
    struct List: View {
        let quotes: [CurrencyModel.Quote]
        @ObservedObject var userInput: UserInputViewModel
        var body: some View {
            SwiftUI.List(self.quotes) { quote in
                ViewSwitch(quote: quote,
                           amount: self.userInput.formattedPrice(withRate: quote.rate))
            }
        }
    }
}

extension Converter.List {
    // Switch statements are not allowed in ViewBuilders
    // This simple ViewSwitch helps me change the view based
    // on the state of the model
    fileprivate struct ViewSwitch: View {
        let quote: CurrencyModel.Quote
        let amount: String?
        var body: some View {
            if let amount = self.amount {
                return AnyView(
                    WithPriceCell(flag: quote.flag,
                                  code: quote.code,
                                  amount: amount,
                                  rate: formattedRate(quote.rate))
                )
            } else {
                return AnyView(
                    WithOutPriceCell(flag: quote.flag,
                                     code: quote.code,
                                     rate: formattedRate(quote.rate))
                )
            }
        }
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

fileprivate func formattedRate(_ rate: Double) -> String {
    "1:" + formatter.string(from: .init(value: rate))!
}

// Required for List
extension CurrencyModel.Quote: Identifiable {
    var id: String {
        _key
    }
}

struct List_Preview1: PreviewProvider {
    static var previews: some View {
        let data: [CurrencyModel.Quote] = TESTING_model.quotes
        return Converter.List(quotes: data, userInput: .init(userInput: "100"))
    }
}

struct List_Preview2: PreviewProvider {
    static var previews: some View {
        let data: [CurrencyModel.Quote] = TESTING_model.quotes
        return Converter.List(quotes: data, userInput: .init(userInput: "100000000"))
    }
}
