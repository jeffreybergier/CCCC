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

struct Converter: View {
    
    @ObservedObject var data: DataViewModel
    @ObservedObject var userInput: UserInputViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Entry(viewModel: self.userInput)
                    .padding()
                Divider()
                Switch(value: self.data.model,
                       userInput: self.userInput)
            }
            .navigationBarTitle("Ｃ四つ", displayMode: .inline)
        }
    }
}

extension Converter {
    // Switch statements are not allowed in ViewBuilders
    // This simple Switch helps me change the view based
    // on the state of the mdoel
    fileprivate struct Switch: View {
        let value: DataViewModel.Value
        let userInput: UserInputViewModel
        var body: some View {
            switch value {
            case .initialLoad:
                return AnyView(VStack{
                    Spacer()
                    Text("Loading…")
                    Spacer()
                })
            case .newValue(let model):
                return AnyView(
                    Converter.List(quotes: model.quotes,
                                   userInput: self.userInput)
                )
            case .error:
                return AnyView(VStack{
                    Spacer()
                    Text("Network Error Ocurred")
                    Spacer()
                })
            }
        }
    }
}

struct Converter_Preview: PreviewProvider {
    static var previews: some View {
        Converter(data: Converter.SWIFT_PREVIEWS_DataViewModel(),
                  userInput: .init(userInput: "100"))
    }
}
