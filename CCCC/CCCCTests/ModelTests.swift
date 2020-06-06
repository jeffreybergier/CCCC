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
        guard let data = exampleRequest.data(using: .utf8) else { XCTFail(); return nil; }
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

private let exampleRequest = """
{\"success\":true,\"terms\":\"https:\\/\\/currencylayer.com\\/terms\",\"privacy\":\"https:\\/\\/currencylayer.com\\/privacy\",\"timestamp\":1591374966,\"source\":\"USD\",\"quotes\":{\"USDAED\":3.673198,\"USDAFN\":77.350186,\"USDALL\":109.774976,\"USDAMD\":481.74033,\"USDANG\":1.794847,\"USDAOA\":585.984502,\"USDARS\":68.985007,\"USDAUD\":1.433466,\"USDAWG\":1.8,\"USDAZN\":1.701218,\"USDBAM\":1.726392,\"USDBBD\":2.018978,\"USDBDT\":84.94435,\"USDBGN\":1.730645,\"USDBHD\":0.377636,\"USDBIF\":1910,\"USDBMD\":1,\"USDBND\":1.393226,\"USDBOB\":6.914582,\"USDBRL\":4.961204,\"USDBSD\":0.999912,\"USDBTC\":0.000103,\"USDBTN\":75.64131,\"USDBWP\":11.600303,\"USDBYN\":2.382028,\"USDBYR\":19600,\"USDBZD\":2.015624,\"USDCAD\":1.342395,\"USDCDF\":1826.000068,\"USDCHF\":0.96258,\"USDCLF\":0.027786,\"USDCLP\":766.70218,\"USDCNY\":7.082041,\"USDCOP\":3555,\"USDCRC\":576.49395,\"USDCUC\":1,\"USDCUP\":26.5,\"USDCVE\":98.050416,\"USDCZK\":23.508014,\"USDDJF\":177.720103,\"USDDKK\":6.604602,\"USDDOP\":57.510509,\"USDDZD\":128.33863,\"USDEGP\":16.235397,\"USDERN\":15.000198,\"USDETB\":34.309863,\"USDEUR\":0.885695,\"USDFJD\":2.190003,\"USDFKP\":0.78761,\"USDGBP\":0.78775,\"USDGEL\":2.964997,\"USDGGP\":0.78761,\"USDGHS\":5.775016,\"USDGIP\":0.78761,\"USDGMD\":51.488836,\"USDGNF\":9534.999879,\"USDGTQ\":7.679515,\"USDGYD\":209.20461,\"USDHKD\":7.75005,\"USDHNL\":24.970179,\"USDHRK\":6.700557,\"USDHTG\":108.66706,\"USDHUF\":304.215972,\"USDIDR\":14000.5,\"USDILS\":3.468902,\"USDIMP\":0.78761,\"USDINR\":75.63255,\"USDIQD\":1190,\"USDIRR\":42104.999705,\"USDISK\":132.020007,\"USDJEP\":0.78761,\"USDJMD\":142.99017,\"USDJOD\":0.709032,\"USDJPY\":109.749532,\"USDKES\":106.150236,\"USDKGS\":74.234299,\"USDKHR\":4121.000432,\"USDKMF\":436.249689,\"USDKPW\":900.041624,\"USDKRW\":1201.655049,\"USDKWD\":0.30804,\"USDKYD\":0.833252,\"USDKZT\":399.62927,\"USDLAK\":9009.999856,\"USDLBP\":1517.189498,\"USDLKR\":185.43777,\"USDLRD\":198.749753,\"USDLSL\":16.860082,\"USDLTL\":2.95274,\"USDLVL\":0.60489,\"USDLYD\":1.405031,\"USDMAD\":9.67625,\"USDMDL\":17.199047,\"USDMGA\":3750.000026,\"USDMKD\":54.439932,\"USDMMK\":1401.907198,\"USDMNT\":2813.969208,\"USDMOP\":7.982099,\"USDMRO\":357.000014,\"USDMUR\":39.805074,\"USDMVR\":15.459813,\"USDMWK\":737.483762,\"USDMXN\":21.56604,\"USDMYR\":4.267501,\"USDMZN\":69.464977,\"USDNAD\":16.860113,\"USDNGN\":388.000178,\"USDNIO\":34.294418,\"USDNOK\":9.293802,\"USDNPR\":121.02638,\"USDNZD\":1.53645,\"USDOMR\":0.385022,\"USDPAB\":0.999912,\"USDPEN\":3.433998,\"USDPGK\":3.455012,\"USDPHP\":49.815041,\"USDPKR\":163.268539,\"USDPLN\":3.926651,\"USDPYG\":6654.1032,\"USDQAR\":3.64125,\"USDRON\":4.284101,\"USDRSD\":104.080203,\"USDRUB\":68.518801,\"USDRWF\":937.5,\"USDSAR\":3.755003,\"USDSBD\":8.336951,\"USDSCR\":17.590485,\"USDSDG\":55.275018,\"USDSEK\":9.191845,\"USDSGD\":1.392285,\"USDSHP\":0.78761,\"USDSLL\":9754.99969,\"USDSOS\":581.000288,\"USDSRD\":7.457976,\"USDSTD\":22050.693068,\"USDSVC\":8.749227,\"USDSYP\":513.034801,\"USDSZL\":16.859818,\"USDTHB\":31.513029,\"USDTJS\":10.286874,\"USDTMT\":3.5,\"USDTND\":2.83375,\"USDTOP\":2.26015,\"USDTRY\":6.783745,\"USDTTD\":6.769617,\"USDTWD\":29.680802,\"USDTZS\":2316.99968,\"USDUAH\":26.591049,\"USDUGX\":3729.808397,\"USDUSD\":1,\"USDUYU\":42.931918,\"USDUZS\":10149.999647,\"USDVEF\":9.987497,\"USDVND\":23265.5,\"USDVUV\":116.355092,\"USDWST\":2.666831,\"USDXAF\":579.00186,\"USDXAG\":0.057607,\"USDXAU\":0.000595,\"USDXCD\":2.70255,\"USDXDR\":0.726977,\"USDXOF\":585.468539,\"USDXPF\":106.179981,\"USDYER\":250.35015,\"USDZAR\":16.80195,\"USDZMK\":9001.200085,\"USDZMW\":18.243975,\"USDZWL\":322.000001}}
"""
