//
//  CacheReadWrite.swift
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

import Combine
import Foundation

private let kCacheURL: URL = {
    let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    return cache.appendingPathComponent("CCCC_cache.plist")
}()

extension Converter.DataViewModel {
    static let cacheRead: Cacher<CurrencyModel>.CacheRead = {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try Data(contentsOf: kCacheURL)
                    let decode = try PropertyListDecoder().decode(Cacher<CurrencyModel>.Cache.self, from: data)
                    DispatchQueue.main.async {
                        promise(.success(decode))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
    static let cacheWrite: Cacher<CurrencyModel>.CacheWrite = { cache in
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try PropertyListEncoder().encode(cache)
                    try data.write(to: kCacheURL)
                    DispatchQueue.main.async {
                        promise(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}

func TESTING_ONLY_deleteCache() throws {
    try FileManager.default.removeItem(at: kCacheURL)
}
