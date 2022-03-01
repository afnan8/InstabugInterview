//
//  InstabugNetworkClientTests.swift
//  InstabugNetworkClientTests
//
//  Created by Yousef Hamza on 1/13/21.
//

import XCTest
@testable import InstabugNetworkClient

class InstabugNetworkClientTests: XCTestCase {
    
    func testSessionInitialized() {
        let sessionManger = SessionManager()
        XCTAssertNotNil(sessionManger.session)
    }

    func testDataTaskReturn() {
        let request = RequestConvertible(baseURL: "https://httpbin.org/", endPoint: "get", method: .get, headers: nil, parameters: nil)
        
        let task = APIClient.instance.dataTask(with: request) { _, _, _ in }
        XCTAssertNotNil(task)
    }
    
    func testGetResquests() {
        let expectation = expectation(description: "get rquest completed")
        let request = RequestConvertible(baseURL: "https://httpbin.org/", endPoint: "get", method: .get, headers: nil, parameters: nil)
        
        var result: OperationResult?
        APIClient.instance.request(with: request) { _result in
            result = _result
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
        XCTAssertNotNil(result)
    }
    
    func testPostResquests() {
        let expectation = expectation(description: "post rquest completed")
        let request = RequestConvertible(baseURL: "https://httpbin.org/", endPoint: "status", method: .post, headers: nil, parameters: ["codes": 200])
        
        var result: OperationResult?
        APIClient.instance.request(with: request) { _result in
            result = _result
            expectation.fulfill()
        }
        waitForExpectations(timeout: 210)
        XCTAssertNotNil(result)
    }
    
    
}
