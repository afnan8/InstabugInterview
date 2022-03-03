//
//  NSManagedObject+Extension.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 02/03/2022.
//

import Foundation
import CoreData

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
    
    static func totalNumber(in context: NSManagedObjectContext) -> Int {
        // Good:
        let countRequest = try! context.count(for: fetchRequest)
        return countRequest
    }
}
