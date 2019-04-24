//
//  GFDataService.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import CoreData

class GFDataService {
    
    init(){}
    
    static var context:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "GenfareDataResources")
        print(container.persistentStoreDescriptions.first?.url)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data Retreving support

    static func fetchRecords(entity:String) -> Array<Any> {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        var records:Array<Any> = []
        do {
            records = try context.fetch(fetchRequest) as Array<Any>
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return records
    }
    
    static func deleteAllRecords(entity:String) {
        let context = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        }catch let error as NSError {
            print("Could not Delete. \(error), \(error.userInfo)")
        }
    }
    
    static func deleteFiredEventRecord(entity:String,clickedTime: NSNumber) {
        let context = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let predicate = NSPredicate(format: "clickedTime == %@", clickedTime as CVarArg)
        deleteFetch.predicate = predicate
        
        do {
            let records = try context.fetch(deleteFetch) as! [NSManagedObject]
            for record in records {
                context.delete(record)
                
            }
        }catch let error as NSError {
            print("Could not Delete. \(error), \(error.userInfo)")
        }
        
    }
    
    static func deletePayAsYouGoWallet(entity:String,wallet:WalletContents) {
        let context = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let predicate = NSPredicate(format: "wallet == %@",wallet)
        do {
            let records = try context.fetch(deleteFetch) as! [NSManagedObject]
            for wallet in records {
                context.delete(wallet)
            }
        }catch let error as NSError {
            print("Could not Delete. \(error), \(error.userInfo)")
        }
        
    }
    
    static func currentAccount() -> Account? {
        let records:Array<Account> = fetchRecords(entity: "Account") as! Array<Account>
        
        if records.count > 0 {
            return records.first
        }
        
        return nil
    }
    
    static func getAddress() -> Array<StoredAddress>?{
        let records:Array<StoredAddress> = fetchRecords(entity: "StoredAddress") as! Array<StoredAddress>
        
        if records.count > 0 {
            return records
        }
        return []
    }
    
    static func getCappedDelay() -> Int {
        let records:Array<Configure> = fetchRecords(entity: "Configure") as! Array<Configure>
        
        if records.count > 0 {
            let record = records.first
            if let cdelay = record?.cappedDelay as? Int {
                return cdelay
            }
        }
        
        return 0
    }

    static func getTransitOffsetValue() -> Int {
        let records:Array<Configure> = fetchRecords(entity: "Configure") as! Array<Configure>
        
        if records.count > 0 {
            let record = records.first
            if let offset = record?.endOfTransitDay as? Int {
                return offset
            }
        }
        
        return 0
    }

}
