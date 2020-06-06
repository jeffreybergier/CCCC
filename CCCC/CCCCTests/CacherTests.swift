//
//  CCCCTests.swift
//  CCCCTests
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

import Combine
import XCTest
@testable import CCCC

class CacherTests: XCTestCase {
    
    typealias _Cache = Cacher<String>.Cache
    typealias _Cacher = Cacher<String>
    
    var token: AnyCancellable?

    func test_cache_valid() throws {
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 4
        
        let cache = _Cache(expirationDate: Date() + 10,
                           payload: "From Cache")
        let cacher =
            _Cacher(originalLoad: {
                XCTFail()
                return Future { $0(.failure(NSError.generic())) }
            }, cacheRead: {
                exp.fulfill()
                return Future { $0(.success(cache)) }
            }, cacheWrite: { cache in
                exp.fulfill()
                XCTAssertEqual(cache.payload, "From Cache")
                return Future { $0(.success(())) }
            }, expiresIn: 3)

        self.token = cacher.observe.sink(receiveCompletion:
            { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    exp.fulfill()
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, "From Cache")
                exp.fulfill()
            }
        )
        self.wait(for: [exp], timeout: 0)
    }
    
    func test_cache_expired() throws {
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 5
        
        let cache = _Cache(expirationDate: Date() - 10,
                           payload: "From Cache")
        let cacher =
            _Cacher(originalLoad: {
                exp.fulfill()
                return Future { $0(.success("From Network")) }
            }, cacheRead: {
                exp.fulfill()
                return Future { $0(.success(cache)) }
            }, cacheWrite: { cache in
                exp.fulfill()
                XCTAssertEqual(cache.payload, "From Network")
                return Future { $0(.success(())) }
            }, expiresIn: 3)

        self.token = cacher.observe.sink(receiveCompletion:
            { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    exp.fulfill()
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, "From Network")
                exp.fulfill()
            }
        )
        self.wait(for: [exp], timeout: 0)
    }
    
    func test_cache_fail() throws {
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 5
        
        let cacher =
            _Cacher(originalLoad: {
                exp.fulfill()
                return Future { $0(.success("From Network")) }
            }, cacheRead: {
                exp.fulfill()
                return Future { $0(.failure(NSError.generic())) }
            }, cacheWrite: { cache in
                exp.fulfill()
                XCTAssertEqual(cache.payload, "From Network")
                return Future { $0(.success(())) }
            }, expiresIn: 3)

        self.token = cacher.observe.sink(receiveCompletion:
            { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    exp.fulfill()
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, "From Network")
                exp.fulfill()
            }
        )
        self.wait(for: [exp], timeout: 0)
    }
    
    func test_networkAndCache_fail() throws {
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 3
        
        let cacher =
            _Cacher(originalLoad: {
                exp.fulfill()
                return Future { $0(.failure(NSError.generic())) }
            }, cacheRead: {
                exp.fulfill()
                return Future { $0(.failure(NSError.generic())) }
            }, cacheWrite: { cache in
                XCTFail()
                return Future { $0(.failure(NSError.generic())) }
            }, expiresIn: 3)

        self.token = cacher.observe.sink(receiveCompletion:
            { completion in
                switch completion {
                case .failure(let error):
                    exp.fulfill()
                    XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. (CCCC error 0.)")
                case .finished:
                    XCTFail()
                }
            }, receiveValue: { value in
                XCTFail()
            }
        )
        self.wait(for: [exp], timeout: 0)
    }

}
