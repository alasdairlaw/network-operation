//
//  MockSessionDataTask.swift
//  NetworkOperation
//
//  Created by Alasdair Law on 19/12/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

internal protocol MockResponse {
    static func response(from url: URL) -> CompletionValues
}

internal enum MockSessionDataTaskError: Error {
    case cancelled
}

internal class MockSessionDataTask: URLSessionDataTask {
    private let mockResponse: CompletionValues
    private let completion: Completion
    
    private var _state: URLSessionTask.State
    override internal var state: URLSessionTask.State {
        get {
            return self._state
        }
        set {
            self._state = newValue
        }
    }
    
    init(mockResponse: CompletionValues, completion: @escaping Completion) {
        self.mockResponse = mockResponse
        self.completion = completion
        self._state = .running
        
        super.init()
    }
    
    override internal func resume() {
        let response = self.mockResponse
        
        if self._state == .running {
            self.completion(response.0, response.1, response.2)
        }
    }
    
    override internal func cancel() {
        self.state = .canceling
        self.completion((nil, nil, MockSessionDataTaskError.cancelled))
    }
}
