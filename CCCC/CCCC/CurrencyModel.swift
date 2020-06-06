//
//  CurrencyModel.swift
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

import Foundation

/*
 Example Schema from: https://currencylayer.com/documentation
 {
     "success": true,
     "terms": "https://currencylayer.com/terms",
     "privacy": "https://currencylayer.com/privacy",
     "timestamp": 1430401802,
     "source": "USD",
     "quotes": {
         "USDAED": 3.672982,
         "USDAFN": 57.8936,
         "USDALL": 126.1652,
         "USDAMD": 475.306,
         "USDANG": 1.78952,
         "USDAOA": 109.216875,
         "USDARS": 8.901966,
         "USDAUD": 1.269072,
         "USDAWG": 1.792375,
         "USDAZN": 1.04945,
         "USDBAM": 1.757305,
     [...]
     }
 }
 */

struct CurrencyModel: Codable {
    var terms: URL
    var privacy: URL
    var source: String
    var quotes: [String: Double]
}
