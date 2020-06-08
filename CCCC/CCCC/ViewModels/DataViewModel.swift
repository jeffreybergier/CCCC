//
//  CurrencyDataSource.swift
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

extension Converter {
    
    // Real Data Source Used for the App
    // See `SwiftPreviewsContent.swift` for the mock subclass for Swift Previews
    class ProductionDataViewModel: DataViewModel {
        init() {
            super.init(networkLoad: DataViewModel.networkLoad, expiresIn: 60*30) // 30 minute timer
        }
    }
    
    class DataViewModel: ObservableObject {
        
        typealias Value = Cacher<Model>.Value
        
        @Published var model: Value = .initialLoad
        
        private let cacher: Cacher<Model>
        
        init(networkLoad: @escaping Cacher<Model>.OriginalLoad,
             expiresIn: TimeInterval)
        {
            self.cacher = Cacher<Model>(originalLoad: networkLoad,
                                                cacheRead: DataViewModel.cacheRead,
                                                cacheWrite: DataViewModel.cacheWrite,
                                                expiresIn: expiresIn)
            self.token = self.cacher.observe.assign(to: \.model, on: self)
        }
        
        private var token: AnyCancellable?
        
        deinit {
            self.token?.cancel()
        }
    }
}
