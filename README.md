# network-operation
NSOperation subclass for network requests

## Requirements

- Swift 3.0.1
- Xcode 8.1+

## Installation

### Embedded Framework

- Add as a submodule to your git repository
- Add NetworkOperation.framework to your application's Xcode project
- Add NetworkOperation.framework to the project's Embedded Binaries

## Usage

### Making a Request

Example:

```swift
import NetworkOperation

let operationQueue = OperationQueue()
    
let session = URLSession.shared
let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
let request = URLRequest(url: url)

let operation = NetworkOperation<JSONResponse>(session: session, request: request) { (response: JSONResponse?, error) in
    guard let posts = response?.data as? [[String: Any]] else {
        return
    }
    use(posts: posts)
}

operationQueue.addOperation(operation)
```

NetworkOperations can be scheduled in a queue just like any other NSOperation subclass.

#### Responses

Instances confirming to `NetworkResponse` allow you to control how the Data returned from `NetworkOperation` is serialised. 

For example, the provided JSONResponse struct serialises the Data returned into Any, where Any is a JSON array or dictionary.

```swift
public struct JSONResponse: NetworkResponse {
    public typealias T = Any
    
    public let response: URLResponse
    public let data: T
    
    public init(response: URLResponse, data: Data) throws {
        self.response = response
        
        self.data = try JSONSerialization.jsonObject(with: data)
    }
}
```

Custom `NetworkResponse` types are provided through the `NetworkOperation`'s generic type parameter.

## License

network-operation is released under the MIT license. See LICENSE for details.