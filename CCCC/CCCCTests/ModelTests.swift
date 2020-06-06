//
//  ModelTests.swift
//  CCCCTests
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
import XCTest
@testable import CCCC

class ModelTests: XCTestCase {
    
    var token: AnyCancellable?
    
    override func tearDownWithError() throws {
        self.token?.cancel()
        self.token = nil
        try? TESTING_ONLY_deleteCache()
    }
    
    /*
     // Uncomment to test live on network
    func test_networkLoad() {
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 2
        self.token = networkLoad().sink(receiveCompletion: {
            switch $0 {
            case .failure:
                XCTFail()
            case .finished:
                exp.fulfill()
            }
        }, receiveValue: { model in
            exp.fulfill()
        })
        self.wait(for: [exp], timeout: 30)
    }
    */
    
    func test_model_decode() {
        XCTAssertNotNil(self.modelFromFakeData())
    }
    
    private func modelFromFakeData() -> CurrencyModel? {
        guard let data = TESTING_networkResponse.data(using: .utf8) else { XCTFail(); return nil; }
        do {
            return try JSONDecoder().decode(CurrencyModel.self, from: data)
        } catch {
            XCTFail()
            return nil
        }
    }
    
    func test_model_write_read() {
        guard let model = self.modelFromFakeData() else { XCTFail(); return; }
        let exp = XCTestExpectation()
        exp.expectedFulfillmentCount = 2
        let now = Date()
        let cache = Cacher.Cache(expirationDate: now, payload: model)
        
        self.token =
            cacheWrite(cache)
                .flatMap { cacheRead() }
                .sink(receiveCompletion: {
                    guard case .finished = $0 else { XCTFail(); return; }
                    exp.fulfill()
                }, receiveValue: { testCache in
                    XCTAssertEqual(cache, testCache)
                    exp.fulfill()
                })
        self.wait(for: [exp], timeout: 0.1)
    }
}
