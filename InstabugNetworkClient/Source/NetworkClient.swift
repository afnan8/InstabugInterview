//
//  NetworkClient.swift
//  InstabugNetworkClient
//
//  Created by Yousef Hamza on 1/13/21.
//

import Foundation

public typealias HTTPHeaders = [String: String]

public enum OperationResult {
    // reponse.
    case result(_ : Data?, _ : HTTPURLResponse?)
    // An error.
    case error(_ : APIError?, _ : HTTPURLResponse?)
}

open class NetworkClient: NSObject, ResponseValidation {
    
    static public let instance = NetworkClient()
    
    var sessionManager: SessionManager?
    
    let dispatchQueue = DispatchQueue.global()
    
    private init(sessionManager: SessionManager = SessionManager()) {
        super.init()
        self.sessionManager = sessionManager
    }
    
    internal func dataTask(with request: URLRequestConvertible, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
        guard let urlRequest = try? request.asURLRequest() else {
            completionHandler(nil, nil, APIError.invalidRequest)
            return nil
        }
        
        let dataTask = sessionManager?.session?.dataTask(with: urlRequest) { (data, response, error) in
            completionHandler(data, response, error)
        }
        return dataTask
    }
    
    open func request(with request: URLRequestConvertible, completion: @escaping (OperationResult) -> Void) {
        let task = self.dataTask(with: request, completionHandler: { [weak self] (data, urlResponse, error) in
            guard let self = self else {return}
            self.handelServerResponse(data: data, urlResponse: urlResponse, error: error) { operationResult in
                DispatchQueue.main.async {
                    completion(operationResult)
                }
                self.saveRequestData(request: request, operationResult: operationResult)
            }
        })
        task?.resume()
    }
    
    func validateRequest() {
        let context = PersistentContainer.shared.viewContext
        dispatchQueue.sync() {
            print("recordsLimitValidation start")
            RequestOperations.shared.recordsLimitValidation(in: context)
            print("recordsLimitValidation finished")
        }
    }
    
    func saveRequestData(request: URLRequestConvertible, operationResult: OperationResult) {
        let context = PersistentContainer.shared.viewContext
        let requestConvertable = RequestConvertible(for: request)
        dispatchQueue.async() { [weak self] in
            defer {
                self?.validateRequest()
            }
            print("save request start")
            RequestOperations.shared.save(context: context, values: requestConvertable, operationResult: operationResult)
            print("save request finished")
        }
    }
    
    func handelServerResponse(data: Data?, urlResponse: URLResponse?, error: Error?,  completion: @escaping (OperationResult) -> Void) {
        guard let urlResponse = urlResponse as? HTTPURLResponse else {
            completion(OperationResult.error(APIError.invalidResponse, nil))
            return
        }
        let result = self.verify(data: data, urlResponse: urlResponse, error: error)
        switch result {
        case .success(let data):
            completion(OperationResult.result(data, urlResponse))
        case .failure(let error):
            completion(OperationResult.error(APIError.unknown(error.localizedDescription), urlResponse))
        }
    }
    
    deinit {
        sessionManager?.session?.finishTasksAndInvalidate()
    }
}
