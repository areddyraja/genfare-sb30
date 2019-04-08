//
//  GFFreeRides.swift
//  Genfare
//
//  Created by vishnu on 03/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import CoreData

class GFLoyalty {
    
    static var isFreeRide = false
    
    func isProductEligibleForCappedRide(product:Product) -> Bool {
        var isCappedRide = false
        let cappedDelay = GFDataService.getCappedDelay()
        let cappedThres = product.cappedThreshold?.intValue
        if cappedThres == -1 || cappedThres == 0 {
            return false
        }
        let offset = GFDataService.getTransitOffsetValue()
        
        //let cappedDelay =
        return isCappedRide
    }
    
    func isProductEligibleForBonusFreeRide(product:Product) -> Bool {
        var isFreeRide = false
        
        return isFreeRide
    }
    
    func getLoyaltyCappedForProduct(product:Product) -> LoyaltyCapped? {
        
        guard let productDesc:String = product.productDescription else {
            return nil
        }
        
        let managedContext = GFDataService.context
        let loyaltyCapped = NSEntityDescription.entity(forEntityName: "LoyaltyCapped", in: managedContext)
        do {
            let fetchRequest:NSFetchRequest = LoyaltyCapped.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "productId == %@ && walletId == %@", product.ticketId?.stringValue ?? "","")
            
            let fetchResults = try managedContext.fetch(fetchRequest)
            
        }catch{
            print("Saving failed")
        }
        
        return nil
    }
    
    func getLoyaltyBonusForProduct(product:Product) -> LoyaltyBonus? {
        
        return nil
    }

}
