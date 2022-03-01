//
//  RequestProtocol.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 28/02/2022.
//

import Foundation

public protocol HTTPRequest {
    var baseURL: String { get }
    var endPoint: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
}

public struct RequestConvertible: HTTPRequest {
    
    public var baseURL: String
    public var endPoint: String
    public var method: HTTPMethod
    public var headers: HTTPHeaders?
    public var parameters: Parameters?
    
    init(baseURL: String, endPoint: String, method: HTTPMethod, headers: HTTPHeaders?, parameters: Parameters?) {
        self.baseURL = baseURL
        self.endPoint = endPoint
        self.method = method
        self.headers = headers
        self.parameters = parameters
    }
    
    init(for request: HTTPRequest) {
        baseURL = request.baseURL
        endPoint = request.endPoint
        method = request.method
        headers = request.headers
        parameters = request.parameters
    }
    
    public func asURLRequest() throws -> URLRequest? {
        
        guard let url = URL(string: baseURL + endPoint) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        
        headers?.forEach({ (key: String, value: String) in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        })
        
        if urlRequest.httpMethod != "GET" {
            let bodyParameters = try?  JSONSerialization.data(
                withJSONObject: parameters ?? [:],
                options: .prettyPrinted)
            urlRequest.httpBody = bodyParameters
        }
        
        return urlRequest
    }
    
    
}
