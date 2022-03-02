//
//  Parameters.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 01/03/2022.
//

import Foundation

public typealias Parameters = [String : Any]
public typealias Payload =  Data?

@propertyWrapper
public struct CustomPayload {
    
    private var value: [String: Any]?

    public init(wrappedValue: [String: Any]?) {
        self.value = wrappedValue
    }
    
    public var projectedValue: Data? {
       get { convertToData() }
     }
    
    public var wrappedValue: [String: Any]? {
        set {
            value = newValue
        }
        get { value }
    }
    
    private func convertToData() -> Data? {
        guard let value = value else {
            return nil
        }
        let bodyParametersData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
        return bodyParametersData?.validate()
    }
}
