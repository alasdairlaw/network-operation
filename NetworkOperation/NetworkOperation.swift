//
//  NetworkOperation.swift
//  NetworkOperation
//
//  Created by Alasdair Law on 17/12/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

/**
    NSOperation subclass which performs a network request.
 */
public class NetworkOperation<T: NetworkResponse>: Operation {
    private let session: URLSession
    private let request: URLRequest
    private let networkCompletion: (_ response: T?, _ error: Error?) -> Void
    
    private var task: URLSessionTask!
    
    private var _isFinished: Bool
    override public var isFinished: Bool {
        get {
            return self._isFinished
        }
        set {
            self.willChangeValue(forKey: NSStringFromSelector(#selector(setter: isFinished)))
            self._isFinished = newValue
            self.didChangeValue(forKey: NSStringFromSelector(#selector(setter: isFinished)))
        }
    }
    
    private var _isExecuting: Bool
    override public var isExecuting: Bool {
        get {
            return self._isExecuting
        }
        set {
            self.willChangeValue(forKey: NSStringFromSelector(#selector(setter: isExecuting)))
            self._isExecuting = newValue
            self.didChangeValue(forKey: NSStringFromSelector(#selector(setter: isExecuting)))
        }
    }
    
    override public var isAsynchronous: Bool {
        return true
    }
    
    /**
     Initialises a NetworkOperation.
     
     - Parameters:
     - request:  The request the network operation should perform.
     - completion:   Block called after the network request has completed, or when the operation was cancelled.
     */
    init(session: URLSession, request: URLRequest, completion: @escaping (_ response: T?, _ error: Error?) -> Void) {
        self.session = session
        self.networkCompletion = completion
        self._isFinished = false
        self._isExecuting = false
        
        self.request = request
        
        super.init()
        
        self.task = self.session.dataTask(with: self.request) { [unowned self] (data, response, error) in
            try? self.handle(data: data, response: response, error: error, nr: T.self)
        }
    }
    
    /**
     Initialises a NetworkOperation.
     
     - Parameters:
     - url:  The URL the network operation should point to.
     - completion:   Block called after the network request has completed, or when the operation was cancelled.
     */
    convenience init(session: URLSession, url: URL, completion: @escaping (_ response: T?, _ error: Error?) -> Void) {
        self.init(session: session, request: URLRequest(url: url), completion: completion)
    }
    
    override public func start() {
        if self.isCancelled {
            self.isFinished = true
        } else if !self.isExecuting {
            self.isExecuting = true
            
            self.task.resume()
        }
    }
    
    override public func cancel() {
        self.isFinished = true
        
        self.task.cancel()
        
        super.cancel()
    }
    
    // MARK: Private
    
    private func handle(data: Data?, response: URLResponse?, error: Error?, nr: T.Type) throws {
        var networkResponse: T?
        defer {
            self.completeNetworkOperation(response: networkResponse, error: error)
        }
        
        guard let response = response as? HTTPURLResponse else {
            return
        }
        guard let data = data else {
            return
        }
        networkResponse = try nr.init(response: response, data: data)
    }
    
    private func completeNetworkOperation(response: T?, error: Error?) {
        if !self.isCancelled {
            self.networkCompletion(response, error)
        }
        
        if self.isExecuting {
            self.isExecuting = false
            self.isFinished = true
        }
    }
}
