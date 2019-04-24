//
//  GFFreeRides.swift
//  Genfare
//
//  Created by vishnu on 03/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import CoreData

protocol LoyaltySupport: WalletProtocol {
    var cappedThreshold: Int { get }
    var cappedDelay: Int { get }
    var bonusThreshold: Int { get }
    var bonusDelay: Int { get }
    var transitOffsetValue: Int { get }
    var loyaltyCappedProductId: Int { get }
    var loyaltyCappedTicketId: Int { get }

    func isCapEnabled(product:Product) -> Bool
    func numberOfRidesForProduct(product: Product, type:LoyaltyType) -> Int
    func rideDelayForCappedProduct(product:Product) -> Int
    func lastRideTimeFor(product:Product,type:LoyaltyType) -> Int
    func isFirstRideFor(product:Product,type:LoyaltyType) -> Bool
    
    func updateCapRecordWithProduct(product:Product) -> Void
    func updateBonusRecordWithProduct(product:Product) -> Void
}

enum LoyaltyType:String {
    case capped = "LoyaltyCapped"
    case bonus = "LoyaltyBonus"
}

class GFLoyalty: LoyaltySupport {

    static var isFreeRide = false
    
    private var _cappedThreshold: Int
    private var _cappedDelay: Int
    private var _bonusThreshold: Int
    private var _bonusDelay: Int
    private var _transitOffsetValue: Int
    private var _loyaltyCappedProductId: Int
    private var _loyaltyCappedTicketId: Int

    convenience init() {
        let records:Array<Configure> = GFDataService.fetchRecords(entity: "Configure") as! Array<Configure>
        
        if records.count > 0, let record = records.first {
            self.init(config:record)
        }else{
            let config = Configure(context: GFDataService.context)
            config.cappedThreshold = 0
            config.cappedDelay = 0
            config.bonusThreshold = 0
            config.bonusDelay = 0
            config.endOfTransitDay = 0
            config.cappedTicketId = 0
            config.bonusTicketid = 0
            self.init(config:config)
        }
    }
    
    init(config:Configure) {
        self._cappedThreshold = config.cappedThreshold as? Int ?? 0
        self._cappedDelay = config.cappedDelay as? Int ?? 0
        self._bonusThreshold = config.bonusThreshold as? Int ?? 0
        self._bonusDelay = config.bonusDelay as? Int ?? 0
        self._transitOffsetValue = config.endOfTransitDay as? Int ?? 0
        self._loyaltyCappedTicketId = config.cappedTicketId as? Int ?? 0
        self._loyaltyCappedProductId = config.cappedTicketId as? Int ?? 0
    }
    
    var loyaltyCappedProductId: Int {
        get {
            return _loyaltyCappedProductId
        }
    }

    var loyaltyCappedTicketId: Int {
        get {
            return _loyaltyCappedTicketId
        }
    }

    var cappedThreshold: Int  {
        get {
            return _cappedThreshold
        }
    }

    var cappedDelay: Int {
        get {
            return _cappedDelay
        }
    }
    
    var bonusThreshold: Int {
        get {
            return _bonusThreshold
        }
    }
    
    var bonusDelay: Int {
        get {
            return _bonusDelay
        }
    }
    
    var transitOffsetValue: Int {
        get {
            return _transitOffsetValue
        }
    }

    func isFirstRideFor(product: Product, type: LoyaltyType) -> Bool {
        
        if isFirstRideWithInDelay() {
            return true
        }else if lastRideTimeFor(product: product, type: type) > 0 {
            return true
        }
        
        return false
    }
    
    func isFirstRideWithInDelay() -> Bool {
        let timeNow = Date().timeIntervalSince1970
        let eotTimeWithDelay = endOfTransitTime()+cappedDelay
        
        return (eotTimeWithDelay > Int(timeNow))
    }
    
    func endOfTransitTime() -> Int {
        let totalSecs = (transitOffsetValue*60)
        let hrs = (totalSecs/3600)
        let mins = (totalSecs - (3600*hrs))/60
        let secs = (totalSecs - (3600*hrs) - (mins*60))
        let eotTimeWithDelay = Calendar.current.date(bySettingHour: hrs, minute: mins, second: secs, of: Date())!.timeIntervalSince1970
        
        return Int(eotTimeWithDelay)
    }
    
    func lastRideTimeFor(product:Product, type:LoyaltyType) -> Int {
        
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
                        //Delete any recortds which are older than the next transit day
                        guard (record.activatedTime?.intValue)! > endOfTransitTime() else {
                            context.delete(record)
                            return 0
                        }
                        return record.activatedTime!.intValue
                    }
                case .bonus:
                    if let record = records.first as? LoyaltyBonus {
                        return record.activatedTime!.intValue
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
    
    func numberOfRidesForProduct(product: Product, type:LoyaltyType) -> Int {
        
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
                        return record.rideCount!.intValue
                    }
                case .bonus:
                    if let record = records.first as? LoyaltyBonus {
                        return record.rideCount!.intValue
                    }
                }
            }
        }catch _ as NSError {
            print("Could not fetch records")
        }
        
        return 0
    }
    
    func rideDelayForCappedProduct(product: Product) -> Int {
        return (Int(Date().timeIntervalSince1970) - lastRideTimeFor(product: product, type: .capped))
    }
    
    func updateCapRecordWithProduct(product: Product) {
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
                if let ridecount = record?.rideCount {
                    record?.rideCount = (Int(truncating: ridecount) + 1) as NSNumber
                }else{
                    record?.rideCount = 1
                }
            }else{
                //Insert new record
                let loyaltyCapped = NSEntityDescription.entity(forEntityName: "LoyaltyCapped", in: managedContext)
                let record = NSManagedObject(entity: loyaltyCapped!, insertInto: managedContext) as! LoyaltyCapped
                
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
        
        guard !isFirstRideFor(product: product, type: .capped) else {
            updateCapRecordWithProduct(product: product)
            return false
        }
        
        guard rideDelayForCappedProduct(product: product) >= cappedDelay else {
            //updateCapRecordWithProduct(product: product)
            return false
        }
        
        guard numberOfRidesForProduct(product: product, type: .capped) >= cappedThreshold else {
            updateCapRecordWithProduct(product: product)
            return false
        }
        
        updateCapRecordWithProduct(product: product)
        
        return true
    }
    
    func isProductEligibleForBonusFreeRide(product:Product) -> Bool {
        
        guard let bonusStatus = product.isBonusRideEnabled, bonusStatus == 1 else {
            return false
        }
        
        guard bonusThreshold != -1, bonusThreshold != 0 else {
            return false
        }
        
        guard numberOfRidesForProduct(product: product, type: .bonus) >= bonusThreshold else {
            updateBonusRecordWithProduct(product: product)
            return false
        }
        
        updateBonusRecordWithProduct(product: product)
        
        return true

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