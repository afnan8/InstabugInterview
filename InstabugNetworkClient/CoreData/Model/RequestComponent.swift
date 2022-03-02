//
//  RequestComponent.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 01/03/2022.
//

import Foundation
import CoreData

@objc(Request)
final class Request: NSManagedObject, Identifiable {

    @NSManaged public var httpMethod: String?
    @NSManaged public var payload: Data?
    @NSManaged public var requestURL: URL?
    
}
/// Defines a convenience class for `NSManagedObject` types to add common methods and remove boilerplate code.
public protocol Managed: NSFetchRequestResult {
    static var entityName: String { get }
}

extension NSManagedObject: Managed { }
public extension Managed where Self: NSManagedObject {
    /// Returns a `String` of the entity name.
    static var entityName: String { return String(describing: self) }

    /// Creates a `NSFetchRequest` which can be used to fetch data of this type.
    static var fetchRequest: NSFetchRequest<Self> {
        return NSFetchRequest<Self>(entityName: entityName)
    }
}
