//
//  JSONNetworkResponse.swift
//  NetworkOperation
//
//  Created by Alasdair Law on 18/12/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

public struct JSONResponse: NetworkResponse {
    public typealias T = Any
    
    public let response: URLResponse
    public let data: T
    
    public init(response: URLResponse, data: Data) throws {
        self.response = response
        
        self.data = try JSONSerialization.jsonObject(with: data)
    }
}
