//
//  NetworkClient.swift
//  InstabugNetworkClient
//
//  Created by Yousef Hamza on 1/13/21.
//

import Foundation

public enum OperationResult {
    /// reponse.
    case result(_ : Data?, _ : HTTPURLResponse?)
    /// An error.
    case error(_ : APIError?, _ : HTTPURLResponse?)
}

public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String : Any?]

open class APIClient: NSObject, ResponseValidation {
    
    static public let instance = APIClient()
    
    var session: URLSession?

    private override init() {
        super.init()
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForResource = 30
        if #available(iOS 11, *) {
            sessionConfiguration.waitsForConnectivity = true
        }
        self.session = URLSession(configuration: sessionConfiguration)
    }
    
   internal func dataTask(with request: RequestConvertible, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
       guard let urlRequest = try? request.asURLRequest() else {
           completionHandler(nil, nil, APIError.invalidRequest)
           return nil
       }
       let dataTask = session?.dataTask(with: urlRequest) { (data, response, error) in
            completionHandler(data, response, error)
        }
        return dataTask
    }
    
    open func request(with request: HTTPRequest, completion: @escaping (OperationResult) -> Void) {
       
        let requestConvertable = RequestConvertible(for: request)
        
        let task = dataTask(with: requestConvertable, completionHandler: { [weak self] (data, urlResponse, error) in
         
            guard let self = self else {return}
            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                completion(OperationResult.error(APIError.invalidResponse, nil))
                return
            }

            let result = self.verify(data: data, urlResponse: urlResponse, error: error)
            
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    completion(OperationResult.result(data, urlResponse))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(OperationResult.error(APIError.unknown(error.localizedDescription), urlResponse))
                }
            }
            
        })
        task?.resume()
        session?.finishTasksAndInvalidate()
    }
    
    deinit {
        session?.invalidateAndCancel()
        session = nil
    }
    
}


protocol ResponseValidation {
    func verify(data: Data?, urlResponse: HTTPURLResponse?, error: Error?) -> Result<Data, Error>
}
extension ResponseValidation {
    
    func verify(data: Data?, urlResponse: HTTPURLResponse?, error: Error?) -> Result<Data, Error> {
        guard let urlResponse = urlResponse else {
            return .failure(APIError.invalidResponse)
        }
        
        switch urlResponse.statusCode {
        case 200...299:
            if let data = data {
                return .success(data)
            } else {
                return .failure(APIError.noData)
            }
        case 400...499:
            return .failure(APIError.badRequest(error?.localizedDescription))
        case 500...599:
            return .failure(APIError.serverError(error?.localizedDescription))
        default:
            return .failure(APIError.unknown(error?.localizedDescription))
        }
    }
}
