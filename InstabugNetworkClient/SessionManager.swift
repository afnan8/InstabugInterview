//
//  SessionManager.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 01/03/2022.
//

import Foundation

class SessionManager {

    var session: URLSession?
    
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForResource = 30
        sessionConfiguration.waitsForConnectivity = true
        session = URLSession(configuration: sessionConfiguration)
    }
    
    
    deinit {
        session?.invalidateAndCancel()
        session = nil
    }
    
}
