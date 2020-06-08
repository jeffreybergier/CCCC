//
//  ConverterListCells.swift
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

import SwiftUI

extension Converter.List {
    struct WithPriceCell: View {
        let flag: String
        let code: String
        let amount: String
        let rate: String
        var body: some View {
            HStack(alignment: .lastTextBaseline) {
                Text(self.flag)
                    .font(.largeTitle)
                Text(self.amount)
                    .lineLimit(1)
                    .font(Font.title.monospacedDigit())
                Text(self.code)
                    .font(.headline)
                Spacer()
                Text(self.rate)
                    .font(Font.subheadline.monospacedDigit())
            }
        }
    }
    
    struct WithOutPriceCell: View {
        let flag: String
        let code: String
        let rate: String
        var body: some View {
            HStack(alignment: .lastTextBaseline) {
                Text(self.flag)
                    .font(.largeTitle)
                Text(self.code)
                    .font(.title)
                Spacer()
                Text(self.rate)
                    .font(Font.subheadline.monospacedDigit())
            }
        }
    }
}