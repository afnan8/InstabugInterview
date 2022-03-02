//
//  Request.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 01/03/2022.
//

import Foundation
import CoreData

final class Request: NSManagedObject, Identifiable {
    @NSManaged public var httpMethod: String?
    @NSManaged public var payload: Data?
    @NSManaged public var requestURL: URL?
}
