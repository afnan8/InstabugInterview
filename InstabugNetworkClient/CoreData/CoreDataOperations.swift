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
        
    }
    
    func save(context: NSManagedObjectContext, values: RequestConvertible, operationResult: OperationResult) {
        context.perform { [weak self] in
            let responseEntity = Response(context: context)
            let request = Request(context: context)
            switch operationResult {
            case .result(let data, let response):
                let responseSuccess = Success(context: context)
                responseSuccess.payloadBody = data?.validate()
                responseSuccess.statusCode = Int64(response?.statusCode ?? 0)
                responseEntity.success = responseSuccess
            case .error(let error, let response):
                let responseError = ClientError(context: context)
                responseError.errorDomain = error?.localizedDescription
                responseError.errorCode = Int64(response?.statusCode ?? 0)
                responseEntity.clientError = responseError
            }
            request.httpMethod = values.method.rawValue
            request.payload = values.$parameters
            request.requestURL = URL(string: values.baseURL + values.endPoint)
            self?.save(context: context)
        }
    }
    
    func recordsLimitValidation(in context: NSManagedObjectContext) {
        context.perform { [weak self] in
            let fetchRequests = Request.fetchRequest()
            let fetchResponses = Response.fetchRequest()
            self?.limitValidation(context: context,
                                  fetchRequests: fetchRequests, fetchResponses)
            
        }
    }
    
    func limitValidation(context: NSManagedObjectContext, fetchRequests: NSFetchRequest<NSFetchRequestResult>...) {
        do {
            for fetchRequest in fetchRequests {
                fetchRequest.shouldRefreshRefetchedObjects = true
                let records = try context.fetch(fetchRequest)
                if  records.count > 1000 {
                    guard let record = records.first as? NSManagedObject else {
                        throw CoreDataError.entityTypeError
                    }
                    context.delete(record)
                    save(context: context)
                }
            }
            print("requests count \(try context.fetch(fetchRequests[0]).count), Responses count \(try context.fetch(fetchRequests[0]).count))")
        } catch {
            print("Failed to delete record: \(error)")
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            context.reset()
        } catch {
            print("Error: Failed to insert save request: \(error)")
        }
    }
    
    public func deleteAllRecords() {
        DispatchQueue.global().async {
            let storeContainer = PersistentContainer.shared.persistentStoreCoordinator
            do {
                // Delete each existing persistent store
                for store in storeContainer.persistentStores {
                    try storeContainer.destroyPersistentStore( at: store.url!, ofType: store.type, options: nil)
                }
            }catch {
                print("Failed to delete records: \(error)")
            }
            PersistentContainer.shared.loadPersistentStores()
        }
    }
}


