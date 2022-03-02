//
//  Response.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 01/03/2022.
//

import Foundation
import CoreData

final class Response: NSManagedObject, Identifiable {
    @NSManaged public var success: Success?
    @NSManaged public var clientError: ClientError?
}

final class Success: NSManagedObject, Identifiable {
    @NSManaged var payloadBody: Data?
    @NSManaged var statusCode: Int64
}

final class ClientError: NSManagedObject, Identifiable {
    @NSManaged public var errorCode: Int64
    @NSManaged public var errorDomain: String?
}
