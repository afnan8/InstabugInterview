//
//  Router.swift
//  InstabugInterview
//
//  Created by Afnan MacBook Pro on 28/02/2022.
//

import Foundation
import InstabugNetworkClient
import CoreLocation

enum Router: URLRequestConvertible {
    
    case getRequest
    case postRequest(_ code: Int)
    case cache
    case responseHeaders
    
    var baseURL: String {
        "https://httpbin.org/"
    }
    
    var endPoint: String {
        switch self {
        case .getRequest:
            return "get"
        case .postRequest(let code):
            return "status/\(code)"
        case .cache:
            return "cache"
        case .responseHeaders:
            return "response-headers"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .postRequest:
            return .post
        default:
            return .get
        }
    }
    
    var headers: HTTPHeaders? { ["Content-Type": "text/plain"] }
    
    var parameters: Parameters? {
        switch self {
        case .getRequest,.postRequest, .cache:
            return nil
        case .responseHeaders:
            return ["freeform": 2]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: baseURL + endPoint)!
        
        switch self {
        case .responseHeaders:
            var components = URLComponents(string: baseURL + endPoint)!
            components.queryItems = parameters?.map { (key, value) in
                URLQueryItem(name: key, value: (value as? String) ?? "")
            }
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            return makeURLRequest(components.url!)
        default:
            return makeURLRequest(url)
        }
    }
    
    func makeURLRequest(_ url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}

