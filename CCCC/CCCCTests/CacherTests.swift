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
    
    override func tearDownWithError() throws {
        self.token?.cancel()
        self.token = nil
    }

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
            }, expiresIn: 10000)

        self.token = cacher.observe.sink(receiveCompletion:
            { _ in
                XCTFail()
            }, receiveValue: { value in
            switch value {
                case .initialLoad:
                    exp.fulfill()
                case .newValue(let value):
                    exp.fulfill()
                    XCTAssertEqual(value, "From Cache")
                case .error:
                    XCTFail()
                }
            }
        )
        self.wait(for: [exp], timeout: 0.1)
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
            }, expiresIn: 10000)

        self.token = cacher.observe.sink(receiveCompletion:
            { _ in
                XCTFail()
            }, receiveValue: { value in
            switch value {
                case .initialLoad:
                    exp.fulfill()
                case .newValue(let value):
                    exp.fulfill()
                    XCTAssertEqual(value, "From Network")
                case .error:
                    XCTFail()
                }
            }
        )
        self.wait(for: [exp], timeout: 0.1)
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
            }, expiresIn: 10000)

        self.token = cacher.observe.sink(receiveCompletion:
            { _ in
                XCTFail()
            }, receiveValue: { value in
            switch value {
                case .initialLoad:
                    exp.fulfill()
                case .newValue(let value):
                    exp.fulfill()
                    XCTAssertEqual(value, "From Network")
                case .error:
                    XCTFail()
                }
            }
        )
        self.wait(for: [exp], timeout: 0.1)
    }
    
    func test_networkAndCache_fail() throws {
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 4
        
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
            }, expiresIn: 10000)

        self.token = cacher.observe.sink(receiveCompletion:
            { _ in
                XCTFail()
            }, receiveValue: { value in
                switch value {
                    case .initialLoad:
                        exp.fulfill()
                    case .newValue:
                        XCTFail()
                    case .error:
                        exp.fulfill()
                    }
            }
        )
        self.wait(for: [exp], timeout: 0.1)
    }
    
    func test_success_repeat() throws {
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 7
        
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
            }, expiresIn: 0.4)

        self.token = cacher.observe.sink(receiveCompletion:
            { completion in
                XCTFail()
            }, receiveValue: { value in
                switch value {
                case .initialLoad:
                    exp.fulfill()
                case .newValue(let value):
                    exp.fulfill()
                    XCTAssertEqual(value, "From Network")
                case .error:
                    XCTFail()
                }
            }
        )
        self.wait(for: [exp], timeout: 1)
    }
    
    func test_fail_repeat() throws {
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 7
        
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
            }, expiresIn: 0.4)

        self.token = cacher.observe.sink(receiveCompletion:
            { completion in
                XCTFail()
            }, receiveValue: { value in
                switch value {
                case .initialLoad:
                    exp.fulfill()
                case .newValue:
                    XCTFail()
                case .error:
                    exp.fulfill()
                }
            }
        )
        self.wait(for: [exp], timeout: 1)
    }
}
