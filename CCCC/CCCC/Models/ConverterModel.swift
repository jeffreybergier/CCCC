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
extension Converter {
    struct Model: Codable, Hashable {
        private var _quotes: QuoteWrapper
        var quotes: [Quote] {
            _quotes.values
        }
        
        private enum CodingKeys: String, CodingKey {
            case _quotes = "quotes"
        }
        
        struct Quote: Hashable {
            var rate: Double
            var code: String
            var flag: String {
                flagMap[self.code] ?? "🏳️"
            }
            
            fileprivate var _key: String
            
            init(key: String, value: Double) throws {
                guard key.count == 6 else { throw NSError.generic() }
                
                self._key = key
                self.rate = value
                
                let middleIndex = key.index(key.startIndex, offsetBy: 3)
                self.code = String(key[middleIndex..<key.endIndex])
            }
        }
    }
}

// Required for List
extension Converter.Model.Quote: Identifiable {
    var id: String {
        _key
    }
}

// Wrapper allows me to build [Quote] from JSON Dictionary
fileprivate struct QuoteWrapper: Codable, Hashable {
    var values: [Converter.Model.Quote]
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dictionary = try container.decode([String: Double].self)
        self.values = try dictionary.compactMap { try .init(key: $0.key, value: $0.value) }
                                    .sorted(by: { $0._key < $1._key })
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let dictionary = Dictionary(uniqueKeysWithValues: self.values.map { ($0._key, $0.rate) })
        try container.encode(dictionary)
    }
}

private let flagMap: [String: String] = [
    "FJD": "🇫🇯",
    "TWD": "🇹🇼",
    "SLL": "🇸🇱",
    "CDF": "🇨🇩",
    "MKD": "🇲🇰",
    "KMF": "🇰🇲",
    "RSD": "🇷🇸",
    "FKP": "🇫🇰",
    "KPW": "🇰🇵",
    "BYN": "🇧🇾",
    "KGS": "🇰🇬",
    "VND": "🇻🇳",
    "IMP": "🇮🇲",
    "SDG": "🇸🇩",
    "SZL": "🇸🇿",
    "MDL": "🇲🇩",
    "TRY": "🇹🇷",
    "SRD": "🇸🇷",
    "LBP": "🇱🇧",
    "HUF": "🇭🇺",
    "GMD": "🇬🇲",
    "CUC": "🇨🇺",
    "MRO": "🇲🇷",
    "SVC": "🇸🇻",
    "GIP": "🇬🇮",
    "ZMW": "🇿🇲",
    "SCR": "🇸🇨",
    "LVL": "🇱🇻",
    "BMD": "🇧🇲",
    "GGP": "🇬🇬",
    "JOD": "🇯🇴",
    "YER": "🇾🇪",
    "RON": "🇷🇴",
    "ZMK": "🇿🇲",
    "HNL": "🇭🇳",
    "GNF": "🇬🇳",
    "BOB": "🇧🇴",
    "MZN": "🇲🇿",
    "PKR": "🇵🇰",
    "AOA": "🇦🇴",
    "WST": "🇼🇸",
    "LRD": "🇱🇷",
    "QAR": "🇶🇦",
    "MMK": "🇲🇲",
    "NAD": "🇳🇦",
    "AED": "🇦🇪",
    "MGA": "🇲🇬",
    "CZK": "🇨🇿",
    "NGN": "🇳🇬",
    "SAR": "🇸🇦",
    "SOS": "🇸🇴",
    "DOP": "🇩🇴",
    "LKR": "🇱🇰",
    "HRK": "🇭🇷",
    "AFN": "🇦🇫",
    "JPY": "🇯🇵",
    "DZD": "🇩🇿",
    "KZT": "🇰🇿",
    "AZN": "🇦🇿",
    "PGK": "🇵🇬",
    "HKD": "🇭🇰",
    "BHD": "🇧🇭",
    "GTQ": "🇬🇹",
    "UAH": "🇺🇦",
    "OMR": "🇴🇲",
    "PHP": "🇵🇭",
    "MYR": "🇲🇾",
    "TND": "🇹🇳",
    "BZD": "🇧🇿",
    "HTG": "🇭🇹",
    "RWF": "🇷🇼",
    "JMD": "🇯🇲",
    "STD": "🇸🇹",
    "PYG": "🇵🇾",
    "IRR": "🇮🇷",
    "MVR": "🇲🇻",
    "KWD": "🇰🇼",
    "BAM": "🇧🇦",
    "DJF": "🇩🇯",
    "COP": "🇨🇴",
    "DKK": "🇩🇰",
    "EUR": "🇪🇺",
    "PLN": "🇵🇱",
    "VEF": "🇻🇪",
    "ZAR": "🇿🇦",
    "INR": "🇮🇳",
    "UGX": "🇺🇬",
    "CHF": "🇨🇭",
    "MNT": "🇲🇳",
    "MWK": "🇲🇼",
    "UZS": "🇺🇿",
    "BND": "🇧🇳",
    "EGP": "🇪🇬",
    "CVE": "🇨🇻",
    "MXN": "🇲🇽",
    "LAK": "🇱🇦",
    "ISK": "🇮🇸",
    "BWP": "🇧🇼",
    "XAF": "🇨🇫",
    "PEN": "🇵🇪",
    "CLF": "🇨🇱",
    "ARS": "🇦🇷",
    "LYD": "🇱🇾",
    "RUB": "🇷🇺",
    "BDT": "🇧🇩",
    "TTD": "🇹🇹",
    "TMT": "🇹🇲",
    "JEP": "🇯🇪",
    "AUD": "🇦🇺",
    "NIO": "🇳🇮",
    "KES": "🇰🇪",
    "SEK": "🇸🇪",
    "GHS": "🇬🇭",
    "GBP": "🇬🇧",
    "VUV": "🇻🇺",
    "SBD": "🇸🇧",
    "MAD": "🇲🇦",
    "NZD": "🇳🇿",
    "BRL": "🇧🇷",
    "CUP": "🇨🇺",
    "GEL": "🇬🇪",
    "ILS": "🇮🇱",
    "NOK": "🇳🇴",
    "BTN": "🇧🇹",
    "CRC": "🇨🇷",
    "CNY": "🇨🇳",
    "CAD": "🇨🇦",
    "AWG": "🇦🇼",
    "SHP": "🇸🇭",
    "MOP": "🇲🇴",
    "NPR": "🇳🇵",
    "ZWL": "🇿🇼",
    "LSL": "🇱🇸",
    "BYR": "🇧🇾",
    "PAB": "🇵🇦",
    "CLP": "🇨🇱",
    "AMD": "🇦🇲",
    "LTL": "🇱🇹",
    "KHR": "🇰🇭",
    "GYD": "🇬🇾",
    "UYU": "🇺🇾",
    "BIF": "🇧🇮",
    "TJS": "🇹🇯",
    "KYD": "🇰🇾",
    "SGD": "🇸🇬",
    "IDR": "🇪🇷",
    "THB": "🇹🇭",
    "BGN": "🇧🇬",
    "IQD": "🇮🇶",
    "SYP": "🇸🇾",
    "BSD": "🇧🇸",
    "MUR": "🇲🇺",
    "KRW": "🇰🇷",
    "TZS": "🇹🇿",
    "USD": "🇺🇸",
    "ETB": "🇪🇹"
]
