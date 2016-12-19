//
//  MockURLSession+JSON.swift
//  NetworkOperation
//
//  Created by Alasdair Law on 18/12/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

struct MockJSONResponse: MockResponse {
    static func response(from url: URL) -> (Data?, URLResponse?, Error?) {
        let jsonObject = [
            "test": "success"
        ]
        let data = try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "https", headerFields: nil)
        
        return (data, response, nil)
    }
}
