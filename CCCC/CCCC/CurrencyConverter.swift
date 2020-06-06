//
//  ContentView.swift
//  CCCC
//
//  Created by Jeffrey Bergier on 2020/06/05.
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

struct CurrencyConverter: View {
    
    @ObservedObject var dataSource: AbstractCurrencyDataSource
    @State var currencyInput = ""
    
    var body: some View {
        NavigationView {
            VStack {
                CurrencyEntry(entry: $currencyInput).padding()
                ViewSwitch(value: $dataSource.model, currencyFromAmount: $currencyInput)
            }
            .navigationBarTitle("Ｃ四つ", displayMode: .inline)
        }
    }
}

struct CurrencyConverter_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyConverter(dataSource: SWIFT_PREVIEWS_currencyDataSource())
    }
}

// Switch statements are not allowed in ViewBuilders
// This simple ViewSwitch helps me change the view based
// on the state of the mdoel
struct ViewSwitch: View {
    @Binding var value: CurrencyDataSource.Base.Value
    @Binding var currencyFromAmount: String
    var body: some View {
        switch value {
        case .initialLoad:
            return AnyView(VStack{
                Spacer()
                Text("Loading…")
                Spacer()
            })
        case .newValue(let model):
            return AnyView(CurrencyTable(data: model.quotes,
                                         currencyFromAmount: currencyFromAmount))
        case .error:
            return AnyView(VStack{
                Spacer()
                Text("Network Error Ocurred")
                Spacer()
            })
        }
    }
}
