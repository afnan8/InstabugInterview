//
//  InstabugCoreDataTests.swift
//  InstabugNetworkClientTests
//
//  Created by Afnan MacBook Pro on 02/03/2022.
//

import XCTest
@testable import InstabugNetworkClient

class InstabugCoreDataTests: XCTestCase {

    func testSaveNewRecord() {
        let expectation = expectation(description: "saveRequestData")
        let context = PersistentContainer.shared.newBackgroundContext()
        let request = RequestConvertible(baseURL: "https://httpbin.org/", endPoint: "get", method: .get, headers: nil, parameters: nil)
        NetworkClient.instance.request(with: request) { _result in
            NetworkClient.instance.saveRequestData(request: request, operationResult: _result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 100)
        XCTAssertNotNil(Request.totalNumber(in:context))
    }
    
    func testLoadingNetworkRequests() {
        testSaveNewRecord()
        let context = PersistentContainer.shared.newBackgroundContext()
        let requestsCount = Request.totalNumber(in: context)
        let responsesCount = Response.totalNumber(in: context)
        XCTAssertTrue(requestsCount > 0 && responsesCount > 0)
    }
    
    func testRecordsLimit() {
        let context = PersistentContainer.shared.newBackgroundContext()
        let expectedCount = 1000
        let requestCount = Request.totalNumber(in: context)
        let responsesCount = Response.totalNumber(in: context)
        XCTAssertTrue(requestCount <= expectedCount)
        XCTAssertTrue(responsesCount <= expectedCount)
    }

}

