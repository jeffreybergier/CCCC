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
    @State var data: [CurrencyModel.Quote]
    var body: some View {
        List(self.data) { quote in
            HStack {
                Text(quote.toFlag).font(.largeTitle)
                Text(quote.to).font(.headline)
                Spacer()
                Text(String(quote.value)).font(.subheadline)
            }
        }
    }
}

struct CurrencyTable_Previews: PreviewProvider {
    static var previews: some View {
        let data: [CurrencyModel.Quote] = [
            try! .init(key: "USDUSD", value: 1.0),
            try! .init(key: "USDJPY", value: 1.254),
            try! .init(key: "USDCAD", value: 1.56),
            try! .init(key: "USDEUR", value: 1.323),
            try! .init(key: "USDGBP", value: 1.877),
        ]
        return CurrencyTable(data: data)
    }
}
