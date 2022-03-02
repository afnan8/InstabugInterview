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
                responseEntity.error = responseError
            }
            request.httpMethod = values.method.rawValue
            request.payload = values.$parameters
            request.requestURL = URL(string: values.baseURL + values.endPoint)
            self?.save(context: context)
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
    
    func recordsLimitValidation(in context: NSManagedObjectContext) {
        context.perform { [weak self] in
            
            do {
                let fetchRequests = Request.fetchRequest()
                let fetchResponses = Response.fetchRequest()
                fetchRequests.shouldRefreshRefetchedObjects = true
                fetchResponses.shouldRefreshRefetchedObjects = true
                
                let requests = try context.fetch(fetchRequests)
                let responses = try context.fetch(fetchResponses)
                                
                if  requests.count > 999 {
                    guard let record = requests.first as? NSManagedObject else {
                        let error = NSError(domain: "", code: 1000, userInfo: [ NSLocalizedDescriptionKey: "Invalid Entity Type, should be NSManagedObject"])
                        throw error
                    }
                    context.delete(record)
                }
                if responses.count > 999 {
                    guard let record = responses.first as? NSManagedObject else {
                        let error = NSError(domain: "", code: 1000, userInfo: [ NSLocalizedDescriptionKey: "Invalid Entity Type, should be NSManagedObject"])
                        throw error
                    }
                    context.delete(record)
                }
                if fetchResponses.includesPendingChanges || fetchRequests.includesPendingChanges {
                    self?.save(context: context)
                }
                print("requests count \(requests.count), Responses count \(responses.count)")
            } catch {
                print("Failed to delete record: \(error)")
            }
        }
    }
    
    public func deleteAllRecords() {
        let taskContext = PersistentContainer.shared.newBackgroundContext()
        taskContext.perform { [weak self] in
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Request.fetchRequest())
            batchDeleteRequest.resultType = .resultTypeCount
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                self?.save(context: taskContext)
                print("records deleted, count: \(String(describing: batchDeleteResult?.result))")
            } catch {
                print("Failed to delete existing records: \(error)")
            }
        }
    }
    
    
}


