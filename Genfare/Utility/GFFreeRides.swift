//
//  GFFreeRides.swift
//  Genfare
//
//  Created by vishnu on 03/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import CoreData

enum LoyaltyType:String {
    case capped = "LoyaltyCapped"
    case bonus = "LoyaltyBonus"
}

protocol LoyaltyDataProtocol {
    var product:Product { get set }
    var loyaltyConfig:Configure { get }
    var loyaltyType:LoyaltyType { get set }
    var cappedTicketId:Int { get }
    var bonusTicketId:Int { get }
 
    var loyaltyCappedRecord:LoyaltyCapped? { get set }
    var loyaltyBonusRecord:LoyaltyBonus? { get set }

    func isCapEnabled() -> Bool
    func isBonusEnabled() -> Bool

    func updateRecordForLoyalty(type:LoyaltyType) -> Void
    func deleteRecordForLoyalty(type:LoyaltyType) -> Void
    
    func lastCappedRideTime() -> Int
    func lastBonusRideTime() -> Int

    func numberOfRidesForType(type:LoyaltyType) -> Int
    func rideDelayForCappedProduct() -> Int
    func isFirstRideForType(type:LoyaltyType) -> Bool

}

class GFLoyaltyData:LoyaltyDataProtocol {
    var product:Product
    var loyaltyType: LoyaltyType = .capped
    var loyaltyCappedRecord: LoyaltyCapped? = nil
    var loyaltyBonusRecord: LoyaltyBonus? = nil
    
    init(product:Product) {
        self.product = product
    }
}

extension LoyaltyDataProtocol {
    
    var cappedTicketId:Int {
        if let id = loyaltyConfig.cappedTicketId as? Int {
            return id
        }
        return 0
    }
    
    var bonusTicketId:Int {
        if let id = loyaltyConfig.bonusTicketid as? Int {
            return id
        }
        return 0
    }
    
    var loyaltyCappedRecord:LoyaltyCapped? {
        get {
            if let record = loyaltyRecordForProduct(type: .capped) as? LoyaltyCapped {
                return record
            }
            return nil
        }
    }
    
    var loyaltyBonusRecord:LoyaltyBonus? {
        get {
            if let record = loyaltyRecordForProduct(type: .bonus) as? LoyaltyBonus {
                return record
            }
            return nil
        }
    }

    var loyaltyConfig: Configure {
        get {
            let records:Array<Configure> = GFDataService.fetchRecords(entity: "Configure") as! Array<Configure>
            
            if records.count > 0, let record = records.first {
                return record
            }else{
                let entity = NSEntityDescription.entity(forEntityName: "Configure", in: GFDataService.context)
                let config = Configure(entity: entity!, insertInto: GFDataService.context)
                GFDataService.context.reset()
                return config
            }
        }
    }
    
    func lastCappedRideTime() -> Int {
        
        guard loyaltyCappedRecord != nil else {
            return 0
        }
        
        //TODO - Need to check the logic here and also implement delete method here
        if let actTime = loyaltyCappedRecord?.activatedTime?.intValue, actTime > endOfTransitTime() {
            return actTime
        }else{
            deleteRecordForLoyalty(type: .capped)
            return 0
        }
    }
    
    func lastBonusRideTime() -> Int {
        
        guard loyaltyBonusRecord != nil else {
            return 0
        }
        
        if let actTime = loyaltyBonusRecord?.activatedTime?.intValue, actTime > endOfTransitTime() {
            return actTime
        }else{
            return 0
        }
    }
    
    func endOfTransitTime() -> Int {
        guard let transitOffsetValue = loyaltyConfig.endOfTransitDay as? Int else {
            return 0
        }
        
        let totalSecs = (transitOffsetValue*60)
        let hrs = (totalSecs/3600)
        let mins = (totalSecs - (3600*hrs))/60
        let secs = (totalSecs - (3600*hrs) - (mins*60))
        let eotTimeWithDelay = Calendar.current.date(bySettingHour: hrs, minute: mins, second: secs, of: Date())!.timeIntervalSince1970
        
        return Int(eotTimeWithDelay)
    }

    func isCapEnabled() -> Bool {
        if let capped = product.isCappedRideEnabled as? Bool {
            return capped
        }else{
            return false
        }
    }

    func isBonusEnabled() -> Bool {
        if let bonus = product.isBonusRideEnabled as? Bool {
            return bonus
        }else{
            return false
        }
    }

    func updateRecordForLoyalty(type:LoyaltyType) -> Void {
        switch type {
        case .capped:
            updateCapRecord()
        case .bonus:
            updateBonusRecord()
        }
    }
    
    func deleteRecordForLoyalty(type:LoyaltyType) -> Void {
        guard let prodId = product.productId else {
            //Dont update or insert any records without valid product id
            return
        }
        
        let managedContext = GFDataService.context
        if let record = loyaltyRecordForProduct(type: type) as? NSManagedObject {
            managedContext.delete(record)
            return
        }
        
        var fetchRequest:NSFetchRequest<NSFetchRequestResult>
        
        switch type {
        case .capped:
           fetchRequest = LoyaltyCapped.fetchRequest()
        case .bonus:
            fetchRequest = LoyaltyBonus.fetchRequest()
        }
        
        fetchRequest.predicate = NSPredicate(format: "productId = %@", prodId)
        do {
            let fetchresults = try managedContext.fetch(fetchRequest)
            if let record = fetchresults.first as? NSManagedObject {
                managedContext.delete(record)
            }
        }catch _ as NSError {
            print("Could not fetch records")
        }
    }

    func rideDelayForCappedProduct() -> Int {
        return (Int(Date().timeIntervalSince1970) - lastCappedRideTime())
    }

    func numberOfRidesForType(type:LoyaltyType) -> Int {
        switch type {
        case .capped:
            if let record = loyaltyRecordForProduct(type: type) as? LoyaltyCapped,
                let rideCount = record.rideCount as? Int {
                return rideCount
            }
        case .bonus:
            if let record = loyaltyRecordForProduct(type: type) as? LoyaltyBonus,
                let rideCount = record.rideCount as? Int {
                return rideCount
            }
        }
        
        return 0
    }

    func isFirstRideForType(type: LoyaltyType) -> Bool {
        
        if isFirstRideWithInDelay() {
            return true
        }
        
        switch type {
        case .capped:
            if lastCappedRideTime() > 0 {
                return true
            }
        case .bonus:
            if lastBonusRideTime() > 0 {
                return true
            }
        }
        
        return false
    }
    
    func isFirstRideWithInDelay() -> Bool {
        guard let cappedDelay = loyaltyConfig.cappedDelay as? Int else {
            return true
        }
        
        let timeNow = Int(Date().timeIntervalSince1970)
        let eotTimeWithDelay = endOfTransitTime()+cappedDelay
        
        return (eotTimeWithDelay > timeNow)
    }

    func loyaltyRecordForProduct(type:LoyaltyType) -> Any {
        
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
                        return record
                    }
                case .bonus:
                    if let record = records.first as? LoyaltyBonus {
                        return record
                    }
                }
            }
        }catch _ as NSError {
            print("Could not fetch records")
        }
        
        return 0
    }
    
    func updateCapRecord() {
        guard let prodId = product.productId else {
            //Dont update or insert any records without valid product id
            return
        }
        
        let managedContext = GFDataService.context
        let fetchRequest:NSFetchRequest = LoyaltyCapped.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId = %@", prodId)
        
        do {
            let fetchresults = try managedContext.fetch(fetchRequest)
            if fetchresults.count > 0 {
                //update record
                let record = fetchresults.first
                record?.activatedTime = Date().timeIntervalSince1970 as NSNumber
                if let ridecount = record?.rideCount as? Int {
                    record?.rideCount = (ridecount + 1) as NSNumber
                }else{
                    record?.rideCount = 1
                }
            }else{
                //Insert new record
                let loyaltyCapped = NSEntityDescription.entity(forEntityName: "LoyaltyCapped", in: managedContext)
                let record = LoyaltyCapped(entity: loyaltyCapped!, insertInto: managedContext)
                
                record.ticketId = product.ticketId
                record.productId = "\(prodId)"
                record.activatedTime = Date().timeIntervalSince1970 as NSNumber
                record.rideCount = 1
                record.productName = product.productDescription
                record.referenceActivatedTime = Date().timeIntervalSince1970 as NSNumber
            }
            try managedContext.save()
        }catch{
            print("Update failed")
        }
    }
    
    func updateBonusRecord() {
        guard let prodId = product.productId else {
            //Dont update or insert any records without valid product id
            return
        }
        
        let managedContext = GFDataService.context
        let fetchRequest:NSFetchRequest = LoyaltyBonus.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId = %@", prodId)
        
        do {
            let fetchresults = try managedContext.fetch(fetchRequest)
            if fetchresults.count > 0 {
                //update record
                let record = fetchresults.first
                record?.activatedTime = Date().timeIntervalSince1970 as NSNumber
                if let ridecount = record?.rideCount as? Int {
                    record?.rideCount = (ridecount + 1) as NSNumber
                }else{
                    record?.rideCount = 1
                }
            }else{
                //Insert new record
                let loyaltyCapped = NSEntityDescription.entity(forEntityName: "LoyaltyBonus", in: managedContext)
                let record = LoyaltyCapped(entity: loyaltyCapped!, insertInto: managedContext)
                
                record.ticketId = product.ticketId
                record.productId = "\(prodId)"
                record.activatedTime = Date().timeIntervalSince1970 as NSNumber
                record.rideCount = 1
                record.productName = product.productDescription
                record.referenceActivatedTime = Date().timeIntervalSince1970 as NSNumber
            }
            try managedContext.save()
        }catch{
            print("Update failed")
        }
    }

}

