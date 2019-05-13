//
//  GFLoyalty.swift
//  Genfare
//
//  Created by vishnu on 26/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation

class GFLoyaltyService {
    
    var dataProvider:LoyaltyDataProtocol
    
    init(dataProvider:LoyaltyDataProtocol) {
        self.dataProvider = dataProvider
    }
    
    func isProductEligibleForCappedRide() -> Bool {
        dataProvider.loyaltyType = .capped
        let product = dataProvider.product
        let config = dataProvider.loyaltyConfig
        
        guard let capStatus = product.isCappedRideEnabled, capStatus == 1 else {
            return false
        }
        
        guard config.cappedThreshold != -1, config.cappedThreshold != 0 else {
            return false
        }
        
        guard dataProvider.isFirstRideForType(type: .capped) else {
            dataProvider.updateRecordForLoyalty(type: .capped)
            return false
        }
        
        guard let cdelay = config.cappedDelay as? Int, dataProvider.rideDelayForCappedProduct() >= cdelay else {
            //updateCapRecordWithProduct(product: product)
            return false
        }
        
        guard let thold = config.cappedThreshold as? Int, dataProvider.numberOfRidesForType(type: .capped) >= thold else {
            dataProvider.updateRecordForLoyalty(type: .capped)
            return false
        }
        
        dataProvider.updateRecordForLoyalty(type: .capped)

        return true
    }
    
    func isProductEligibleForBonusRide() -> Bool {
        dataProvider.loyaltyType = .bonus
        let product = dataProvider.product
        let config = dataProvider.loyaltyConfig
        
        guard let bonusStatus = product.isBonusRideEnabled, bonusStatus == 1 else {
            return false
        }
        
        guard config.bonusThreshold != -1, config.bonusThreshold != 0 else {
            return false
        }
        
        guard let thold = config.bonusThreshold as? Int, dataProvider.numberOfRidesForType(type: .bonus) >= thold else {
            dataProvider.updateRecordForLoyalty(type: .bonus)
            return false
        }
        
        dataProvider.deleteRecordForLoyalty(type: .bonus)

        return true
    }
    
}
