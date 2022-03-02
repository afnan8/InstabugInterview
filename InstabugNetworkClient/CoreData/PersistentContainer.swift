//
//  PersistentContainerManager.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 01/03/2022.
//

import Foundation
import CoreData

open class PersistentContainer: NSPersistentContainer {
    
    public static let shared = PersistentContainer(name: "InstabugNetworkCoreData")
    
    open override func newBackgroundContext() -> NSManagedObjectContext {
        let context = super.newBackgroundContext()
        context.name = "background_context"
//        context.transactionAuthor = "main_app_background_context"
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    public func loadPersistentStores() {
        loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                 fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
}
