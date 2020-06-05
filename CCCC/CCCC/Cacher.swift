//
//  Cacher.swift
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

import Combine
import Foundation

class Cacher<T: Codable> {
    
    struct Cache: Codable {
        var expirationDate: Date
        var payload: T
    }
    
    enum Change {
        case initialLoad
        case update(T)
    }
    
    typealias OriginalLoad = () -> Future<T, Error>
    typealias CacheRead = () -> Future<Cache, Error>
    typealias CacheWrite = (Cache) -> Future<Void, Error>
    
    // Constants
    private let originalLoad: OriginalLoad
    private let cacheRead: CacheRead
    private let cacheWrite: CacheWrite
    private let expiresIn: TimeInterval
    
    // Observer
    private(set) lazy var observe: AnyPublisher<T, Error> = {
        let now = Date()
        let timer = Timer.TimerPublisher(interval: 0,
                                         runLoop: .main,
                                         mode: .default)
            .autoconnect()
            .mapError { _ in NSError() as Error }
//        return timer
//            .flatMap { [cacheRead] _ in cacheRead() }
        return self.cacheRead()
            .tryMap { cache -> Cache in
                guard now.timeIntervalSince(cache.expirationDate) > 0 else { throw NSError() }
                return cache
            }.catch { [expiresIn, originalLoad] _ in originalLoad().map {
                Cache(
                    expirationDate: now + expiresIn,
                    payload: $0
                )
            }.eraseToAnyPublisher()
            }.flatMap { [cacheWrite] cache in
                cacheWrite(cache).map { cache }
            }.map { $0.payload }
            .eraseToAnyPublisher()
    }()
    
    init(originalLoad: @escaping OriginalLoad,
         cacheRead: @escaping CacheRead,
         cacheWrite: @escaping CacheWrite,
         expiresIn: TimeInterval)
    {
        self.originalLoad = originalLoad
        self.cacheRead = cacheRead
        self.cacheWrite = cacheWrite
        self.expiresIn = expiresIn
    }
}
