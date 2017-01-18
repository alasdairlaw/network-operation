//
//  NetworkResponse.swift
//  NetworkOperation
//
//  Created by Alasdair Law on 18/12/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

public protocol NetworkResponse {
    associatedtype T
    
    var response: URLResponse { get }
    var data: T { get }
    
    init(response: URLResponse, data: Data) throws
}
