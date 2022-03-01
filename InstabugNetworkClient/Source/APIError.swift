//
//  APIError.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 28/02/2022.
//

import Foundation

public enum APIError: Error {
    
    case invalidRequest
    case invalidResponse
    // No data received from the server.
    case noData
    // badRequest: statusCode --> 400-499
    case badRequest(String?)
    // serverError: statusCode --> 500...599
    case serverError(String?)
    // There was an error parsing the data.
    case parseError(String?)
    //failure
    case unknown(String?)
}


