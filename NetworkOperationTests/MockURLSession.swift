//
//  MockURLSession.swift
//  NetworkOperation
//
//  Created by Alasdair Law on 18/12/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

internal typealias CompletionValues = (Data?, URLResponse?, Error?)
internal typealias Completion = (CompletionValues) -> Void

internal class MockSession: URLSession {
    private var mocks = [URL: CompletionValues]()
    
    internal func mock(url: URL, with response: (URL) -> CompletionValues) {
        self.mocks[url] = response(url)
    }
    
    internal func removeMocks() {
        self.mocks.removeAll()
    }
    
    override internal func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        guard let mockResponse = self.mocks[request.url!] else {
            return super.dataTask(with: request, completionHandler: completionHandler)
        }
        return MockSessionDataTask(mockResponse: mockResponse, completion: completionHandler)
    }
}
