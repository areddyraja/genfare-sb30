//
//  GFFreeRides.swift
//  Genfare
//
//  Created by vishnu on 03/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import CoreData

protocol LoyaltySupport:WalletProtocol {
    var cappedThreshold: Int { get }
    var cappedDelay: Int { get }
    var bonusThreshold: Int { get }
    var bonusDelay: Int { get }
    var transitOffsetValue: Int { get }
    
    var isFirstRide: Bool { get }
    
    func isCapEnabled(product:Product) -> Bool
    func numberOfRidesForProduct(product:Product) -> Int
    func rideDelayForCappedProduct(product:Product) -> Int
    func lastRideTimeFor(product:Product,type:LoyaltyType) -> Double
    
    func updateCapRecordWithProduct(product:Product) -> Void
    func updateBonusRecordWithProduct(product:Product) -> Void
}

enum LoyaltyType:String {
    case capped = "LoyaltyCapped"
    case bonus = "LoyaltyBonus"
}

class GFLoyalty: LoyaltySupport {
    
    static var isFreeRide = false

    var cappedThreshold: Int  {
        let records:Array<Configure> = GFDataService.fetchRecords(entity: "Configure") as! Array<Configure>
        
        if records.count > 0 {
            let record = records.first
            if let offset = record?.cappedThreshold as? Int {
                return offset
            }
        }
        
        return 0
    }

    var cappedDelay: Int {
        let records:Array<Configure> = GFDataService.fetchRecords(entity: "Configure") as! Array<Configure>
        
        if records.count > 0 {
            let record = records.first
            if let offset = record?.cappedDelay as? Int {
                return offset
            }
        }
        
        return 0
    }

    var bonusThreshold: Int {
        //TODO - need to implement method
        return 0
    }
    
    var bonusDelay: Int {
        //TODO - need to implement method
        return 0
    }
    
    var transitOffsetValue: Int {
        let records:Array<Configure> = GFDataService.fetchRecords(entity: "Configure") as! Array<Configure>
        
        if records.count > 0 {
            let record = records.first
            if let offset = record?.endOfTransitDay as? Int {
                return offset
            }
        }
        
        return 0
    }
    
    var isFirstRide: Bool {
        
        let timeNow = Date().timeIntervalSince1970
        
        if (Int(timeNow) - transitOffsetValue) < cappedDelay {
            return true
        }else{
            //TODO - check if there are any previous rides
            
        }
        
        return false
    }
    
    func lastRideTimeFor(product:Product, type:LoyaltyType) -> Double {
        
        guard let prodID = product.productId else {
            return 0
        }
        
        let context = GFDataService.context
        let recordFetch = NSFetchRequest<NSFetchRequestResult>(entityName: type.rawValue)
        let predicate = NSPredicate(format: "productId == %@", prodID)
        recordFetch.predicate = predicate
        
        do {
            let records = try context.fetch(recordFetch)
            if records.count > 0 {
                switch type {
                case .capped:
                    if let record = records.first as? LoyaltyCapped {
                        return Double(truncating: record.activatedTime!)
                    }
                case .bonus:
                    if let record = records.first as? LoyaltyBonus {
                        return Double(truncating: record.activatedTime!)
                    }
                }
            }
        }catch _ as NSError {
            print("Could not fetch records")
        }
        
        return 0
    }
    
    func isCapEnabled(product: Product) -> Bool {
        if let capped = product.isCappedRideEnabled as? Bool {
            return capped
        }else{
            return false
        }
    }
    
    func numberOfRidesForProduct(product: Product) -> Int {
        //TODO - need to get number of rides for product
        return 0
    }
    
    func rideDelayForCappedProduct(product: Product) -> Int {
        //TODO - need to get delay for product
        
        return 0
    }
    
    func updateCapRecordWithProduct(product: Product) {
        //TODO - Update record
        
    }
    
    func updateBonusRecordWithProduct(product: Product) {
        //TODO -
    }
    
    func isProductEligibleForCappedRide(product:Product) -> Bool {
        
        guard let capStatus = product.isCappedRideEnabled, capStatus == 1 else {
            return false
        }
        
        guard cappedThreshold != -1, cappedThreshold != 0 else {
            return false
        }
        
        guard !isFirstRide else {
            //TODO - update record with new time stamp
            return false
        }
        
        guard rideDelayForCappedProduct(product: product) >= cappedDelay else {
            //TODO - update record with new time stamp
            return false
        }
        
        guard numberOfRidesForProduct(product: product) >= cappedThreshold else {
            //TODO - update record with new time stamp
            return false
        }
        
        //TODO - update record with new time stamp
        return true
    }
    
    func isProductEligibleForBonusFreeRide(product:Product) -> Bool {
        var isFreeRide = false
        
        return isFreeRide
    }
    
    func getLoyaltyCappedForProduct(product:Product) -> LoyaltyCapped? {
        
        var capped:LoyaltyCapped?
        
        guard let _:String = product.productDescription else {
            return nil
        }
        
        let managedContext = GFDataService.context
        
        do {
            let fetchRequest:NSFetchRequest = LoyaltyCapped.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "productId == %@ && walletId == %@", product.ticketId?.stringValue ?? "",walledId().stringValue )
            
            let fetchResults = try managedContext.fetch(fetchRequest)
            
            if fetchResults.count > 0 {
                capped = fetchResults.last!
            }else{
                //TODO - insert a new record with the product info
            }
        }catch{
            print("Saving failed")
        }
        
        return capped
    }
    
    func getLoyaltyBonusForProduct(product:Product) -> LoyaltyBonus? {
        var bonus:LoyaltyBonus?
        
        guard let _:String = product.productDescription else {
            return nil
        }
        
        let managedContext = GFDataService.context
        
        do {
            let fetchRequest:NSFetchRequest = LoyaltyBonus.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "productId == %@ && walletId == %@", product.ticketId?.stringValue ?? "",walledId().stringValue )
            
            let fetchResults = try managedContext.fetch(fetchRequest)
            
            if fetchResults.count > 0 {
                bonus = fetchResults.last!
            }else{
                //TODO - insert a new record with the product info
            }
        }catch{
            print("Saving failed")
        }
        
        return bonus
    }
    
}
