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
    
    enum Change {
        case initialLoad
        case update(T)
    }
    
    typealias OriginalLoad = ((Result<T, Error>) -> Void) -> Void
    typealias CacheRead = ((Result<(expiration: Date, data: T), Error>) -> Void) -> Void
    typealias CacheWrite = (_ expirationDate: Date, _ data: T) -> Result<Void, Error>
    
    // Constants
    private let originalLoad: OriginalLoad
    private let cacheRead: CacheRead
    private let cacheWrite: CacheWrite
    private let expiresIn: TimeInterval
    
    // Observer
    private let _observe = CurrentValueSubject<Change, Error>(.initialLoad)
    private(set) lazy var observe: AnyPublisher<Change, Error> = {
        return  AnyPublisher(
            _observe.handleEvents(receiveSubscription: { _ in
                self.update()
            })
        )
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
    @objc private func update() {
        self.timer?.invalidate()
        self.timer = nil
        self.work { [unowned self] result in
            switch result {
            case .success(let data):
                self._observe.send(.update(data))
            case .failure(let error):
                self._observe.send(completion: .failure(error))
            }
        }
    }
    
    private func work(completion: @escaping (Result<T, Error>) -> Void) {
        self.cacheRead { [unowned self] result in
            let now = Date()
            if case .success(let tuple) = result, now.timeIntervalSince(tuple.expiration) > 0 {
                let expirationGap = now.timeIntervalSince(tuple.expiration)
                self.resetTimer(with: expirationGap)
                completion(.success(tuple.data))
            } else {
                self.originalLoad { result in
                    switch result {
                    case .success(let data):
                        let expirationDate = now.addingTimeInterval(self.expiresIn)
                        try? self.cacheWrite(expirationDate, data).get()
                        self.resetTimer(with: self.expiresIn)
                        completion(.success(data))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func resetTimer(with interval: TimeInterval) {
        self.timer = Timer.scheduledTimer(timeInterval: interval + 1,
                                          target: self,
                                          selector: #selector(self.update),
                                          userInfo: nil,
                                          repeats: false)
    }
}
