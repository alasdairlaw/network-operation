//
//  NetworkOperationTests.swift
//  NetworkOperationTests
//
//  Created by Alasdair Law on 17/12/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import XCTest
@testable import NetworkOperation

private let mockJSONURL = URL(string: "https://json.test")!

internal class NetworkOperationTests: XCTestCase {
    private var operationQueue = OperationQueue()
    private var mockSession = MockSession()
    
    override internal func setUp() {
        super.setUp()
        
        self.mockSession = MockSession()
        self.mockTestRequests(session: self.mockSession)
    }
    
    override internal func tearDown() {
        super.tearDown()
        
        self.mockSession.removeMocks()
    }
    
    // Mark: Tests
    
    /**
        Test performing a network request, receiving a JSON response.
     
        Intended functionality:
        - Network operation added to queue.
        - Network operation completes with correct response.
        - Operation queue is empty after completion.
     */
    internal func testNetworkOperationFromRequest() {
        let expectation = self.expectation(description: "JSON response")
        
        let request = URLRequest(url: mockJSONURL)
        let operation = NetworkOperation<JSONResponse>(session: self.mockSession, request: request) { (jsonResponse: JSONResponse?, error) in
            XCTAssert(jsonResponse?.data is [String: Any])
            XCTAssert(jsonResponse?.response is HTTPURLResponse)
            expectation.fulfill()
        }
        
        XCTAssert(operation.isAsynchronous)
        self.operationQueue.addOperation(operation)
        
        self.waitForExpectations(timeout: 1.0) { (error) in
        }
        
        XCTAssert(self.operationQueue.operationCount == 0)
    }
    
    /**
        Test performing a network request from a URL, receiving a JSON response.
     
        Intended functionality:
        - Network operation added to queue.
        - Network operation completes with correct response.
        - Operation queue is empty after completion.
     */
    internal func testNetworkOperationFromURL() {
        let expectation = self.expectation(description: "JSON response")
        
        let operation = NetworkOperation<JSONResponse>(session: self.mockSession, url: mockJSONURL) { (jsonResponse: JSONResponse?, error) in
            XCTAssert(jsonResponse?.data is [String: Any])
            XCTAssert(jsonResponse?.response is HTTPURLResponse)
            expectation.fulfill()
        }
        
        XCTAssert(operation.isAsynchronous)
        self.operationQueue.addOperation(operation)
        
        self.waitForExpectations(timeout: 1.0) { (error) in
        }
        
        XCTAssert(self.operationQueue.operationCount == 0)
    }
    
    /**
        Test performing a network request, but cancelling before the network operation
        has completed.
         
        Intended functionality:
        - Network operation added to queue.
        - Network operation cancelled before responding.
        - Operation queue is empty after cancelling all operations.
     */
    internal func testCancellingNetworkOperation() {
        let expectation = self.expectation(description: "JSON response")
        
        let request = URLRequest(url: mockJSONURL)
        let operation = NetworkOperation<JSONResponse>(session: self.mockSession, request: request) { (jsonResponse: JSONResponse?, error) in
            XCTAssert(jsonResponse?.data == nil)
            XCTAssert(jsonResponse?.response == nil)
            
            XCTAssert(error is MockSessionDataTaskError)
            guard let error = error as? MockSessionDataTaskError else {
                return
            }
            XCTAssert(error == .cancelled)
            
            expectation.fulfill()
        }
        
        self.operationQueue.addOperation(operation)
        self.operationQueue.cancelAllOperations()
        
        self.waitForExpectations(timeout: 1.0) { (error) in
        }
        
        XCTAssert(self.operationQueue.operationCount == 0)
    }
    
    // MARK: Private
    
    private func mockTestRequests(session: MockSession) {
        session.mock(url: mockJSONURL) { (url: URL) -> CompletionValues in
            let jsonObject = [
                "test": "success"
            ]
            let data = try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "https", headerFields: nil)
            
            return (data, response, nil)
        }
    }
}
