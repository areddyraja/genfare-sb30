//
//  TestGFLoyalty.swift
//  GenfareTests
//
//  Created by vishnu on 23/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Quick
import Nimble
import CoreData

@testable import Pods_Genfare

class MockLoyaltyData:LoyaltyDataProtocol {
    var product: Product
    
    var loyaltyType: LoyaltyType
    
    init(product:Product) {
        self.product = product
        self.loyaltyType = .capped
    }
    
    var loyaltyConfig: Configure {
        let entity = NSEntityDescription.entity(forEntityName: "Configure", in: GFDataService.context)
        let config = Configure(entity: entity!, insertInto: GFDataService.context)
        
        config.cappedThreshold = 10
        config.cappedDelay = 10
        config.bonusThreshold = 0
        config.bonusDelay = 0
        config.endOfTransitDay = 30
        config.cappedTicketId = 44
        config.bonusTicketid = 43
        
        return config
    }
    
    func updateRecordForLoyalty(type:LoyaltyType) -> Void {
        print("Dummy function - Dont update any records")
    }
    
    func deleteRecordForLoyalty(type:LoyaltyType) -> Void {
        print("Dummy function - Dont update any records")
    }
    
}

class GFLoyaltyServiceSpec: QuickSpec
{
    var successValue = true
    
    override func spec() {

        describe("GFLoyaltyService") {
            
            let entity = NSEntityDescription.entity(forEntityName: "Product", in: GFDataService.context)
            let product = Product(entity: entity!, insertInto: GFDataService.context)
            
            product.isBonusRideEnabled = 1
            product.isCappedRideEnabled = 1
            product.price = "2"
            product.ticketId = 163
            product.offeringId = 83

            let mockData = MockLoyaltyData(product: product)
            let loyalty = GFLoyaltyService(dataProvider: mockData)

            beforeEach {
                
            }
            
            context("test endOfTransitTime", {
                it("should be", closure: {
                    let actual = mockData.endOfTransitTime()
                    let expected = Int(Calendar.current.date(bySettingHour: 0, minute: 30, second: 0, of: Date())!.timeIntervalSince1970)
                    expect(actual).to(equal(expected))
                })
            })
            
            describe("test isProductEligibleForCappedRide", {
                
                context("when capped rides are disabled", {

                    beforeEach {
                        product.isCappedRideEnabled = 0
                    }
                    
                    it("should return false", closure: {
                        let actual = loyalty.isProductEligibleForCappedRide()
                        expect(actual).to(equal(false))
                    })
                })
                
                context("when cappedThreshold is not available", {
                    beforeEach {
                        product.cappedThreshold = 0
                    }
                    
                    it("should return false", closure: {
                        let actual = loyalty.isProductEligibleForCappedRide()
                        expect(actual).to(equal(false))
                    })
                })

                context("when taking a ride first time in a trnsit day", {
                    beforeEach {
                        product.cappedThreshold = 5
                        product.isCappedRideEnabled = 1
                    }
                    
                    it("should return false", closure: {
                        let actual = loyalty.isProductEligibleForCappedRide()
                        expect(actual).to(equal(false))
                    })
                })
                
                context("when ride time difference is less than cappedDelay", {
                    beforeEach {
                        product.cappedThreshold = 5
                        product.isCappedRideEnabled = 1
                    }
                    
                    it("should return false", closure: {
                        let actual = loyalty.isProductEligibleForCappedRide()
                        expect(actual).to(equal(false))
                    })
                })
            })
        }
    }
}
