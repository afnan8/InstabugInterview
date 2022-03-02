//
//  RequestOperations.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 01/03/2022.
//

import Foundation
import CoreData

open class RequestOperations {
    
    public static let shared = RequestOperations()
    
    private init() {
        PersistentContainer.shared.loadPersistentStores()
    }
    
    func save(values: RequestConvertible, operationResult: OperationResult) {
        let context = PersistentContainer.shared.newBackgroundContext()
//        if recordsExceedLimit(in: context) {
//            DispatchQueue.global().sync {
//                removeFirstRecord(in: context)
//            }
//        }
        let requests = try! context.fetch(Request.fetchRequest)
        print(requests.count)
        (0..<1000).forEach { index in
            if recordsExceedLimit(in: context) {
                DispatchQueue.global().sync {
                    removeFirstRecord(in: context)
                    save(context: context)
                }
            }
            DispatchQueue.global().sync {
                let request = Request(context: context)
                request.httpMethod = values.method.rawValue
                request.payload = values.$parameters
                request.requestURL =  URL(string: values.baseURL + values.endPoint)
                save(context: context)
            }
        }
    }
    
    func fetchFirstRequest(context: NSManagedObjectContext) -> NSFetchRequestResult? {
        do {
            let fetchRequest = Request.fetchRequest()
            let requests = try context.fetch(fetchRequest)
            return requests.first
        } catch {
            print("Failed to delete record: \(error)")
        }
        return nil
    }
    
    func removeFirstRecord(in context: NSManagedObjectContext) {
        let record = fetchFirstRequest(context: context)
        context.delete(record as! NSManagedObject)
        save(context: context)
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            context.reset()
        } catch {
            print("Error: Failed to insert save request: \(error)")
        }
        
        let requests = try! context.fetch(Request.fetchRequest)
        print(requests.count)

    }
    
    func recordsExceedLimit(in context: NSManagedObjectContext) -> Bool {
        let countRequest = try! context.count(for: Request.fetchRequest)
        return countRequest > 999
    }
    
    public func deleteAllRecords() {
        let taskContext = PersistentContainer.shared.newBackgroundContext()
        taskContext.perform {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Request.fetchRequest())
            batchDeleteRequest.resultType = .resultTypeCount
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                try taskContext.save()
                taskContext.reset()
                print("### \(#function): Batch deleted post count: \(String(describing: batchDeleteResult?.result))")
            } catch {
                print("### \(#function): Failed to batch delete existing records: \(error)")
            }
        }
    }
}


