//
//  ResponseValidation.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 02/03/2022.
//

import Foundation

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
