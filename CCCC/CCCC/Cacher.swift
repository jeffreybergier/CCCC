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
    
    enum Value {
        case initialLoad
        case newValue(T)
        case error(Error)
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
    private let _observe: CurrentValueSubject<Value, Never> = .init(.initialLoad)
    private(set) lazy var observe: AnyPublisher<Value, Never> = {
        return _observe.handleEvents(receiveSubscription: { [weak self] _ in
            // Dispatch Async so the subscription finishes before calling `update`
            DispatchQueue.main.async { self?.update() }
        }, receiveCancel: { [weak self] in
            // cleanup when we're done
            self?.timer?.invalidate()
            self?.timer = nil
        })
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
    
    private var timer: Timer?
    private var token: AnyCancellable?
    @objc private func update() {
        // Configure the timer if needed
        if timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: self.expiresIn,
                                              target: self,
                                              selector: #selector(self.update),
                                              userInfo: nil,
                                              repeats: true)
            // if this is first load we also want to send the ".initialLoading" state
            self._observe.send(.initialLoad)
        }
        self.token =
            // 1) Try to load from the cache
            self.cacheRead()
            // 2) If the cache is expired throw an error down the stream
            .tryMap { cache -> Cache in
                guard cache.expirationDate.timeIntervalSince(Date()) > 0
                    else { throw NSError.generic() }
                return cache
            // 3) Catch any cache errors and convert them
            //    into a network request
            }.catch { [expiresIn, originalLoad] _ in
                // 4) Convert the network request into something cachable
                return originalLoad().map {
                    Cache(
                        expirationDate: Date() + expiresIn,
                        payload: $0
                    )
                }
            // 5) Cache the network request to disk
            //    This has the side effect of also caching
            //    the original cache to the disk again
            //    later we could find a way to take that out if needed
            }.flatMap { [cacheWrite] cache in
                cacheWrite(cache).map { cache }
            }.map { $0.payload }
            // 6) Get the final values out and send them through our publisher
            .sink(receiveCompletion: { [weak self] in
                guard case .failure(let error) = $0 else { return }
                self?._observe.send(.error(error))
                self?.invalidate()
            }, receiveValue: { [weak self] in
                self?._observe.send(.newValue($0))
                self?.invalidate()
            })
    }
    
    private func invalidate() {
        self.token?.cancel()
        self.token = nil
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        self.invalidate()
        // In DEBUG mode print deinit to verify no
        // memory leaks during unit testing
        assert({ print("DEINIT"); return true; }())
    }
}

extension NSError {
    static func generic() -> Error {
        return NSError(domain: "CCCC", code: 0, userInfo: nil)
    }
}
