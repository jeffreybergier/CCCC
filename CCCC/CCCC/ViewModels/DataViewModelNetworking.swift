//
//  NetworkLoad.swift
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

private let kAPIKey: String = {
    fatalError("Don't check private keys into the repo")
}()

private let kAPIURL: URL = {
    var c = URLComponents(string: "http://api.currencylayer.com/live")!
    c.queryItems = [
        .init(name: "access_key", value: kAPIKey)
    ]
    return c.url!
}()

extension Converter.DataViewModel {
    static let networkLoad: Cacher<Converter.Model>.OriginalLoad = {
        Future { promise in
            let task = URLSession.shared.dataTask(with: kAPIURL) { (data, response, error) in
                let q = DispatchQueue.main
                guard response?.isValid == true else {
                    q.async { promise(.failure(error ?? NSError.generic())) }
                    return
                }
                if let error = error {
                    q.async { promise(.failure(error)) }
                    return
                }
                guard let data = data else {
                    q.async { promise(.failure(NSError.generic())) }
                    return
                }
                do {
                    let model = try JSONDecoder().decode(Converter.Model.self, from: data)
                    q.async { promise(.success(model)) }
                } catch {
                    q.async { promise(.failure(error)) }
                }
            }
            task.resume()
        }
    }
}

extension URLResponse {
    fileprivate var isValid: Bool {
        guard let response = self as? HTTPURLResponse else { return false }
        switch response.statusCode {
        case 200..<300:
            return true
        default:
            return false
        }
    }
}
