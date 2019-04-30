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

class GFLoyaltySpec: QuickSpec
{
    var successValue = true
    
    override func spec() {

        describe("GFLoyalty") {

            let entity = NSEntityDescription.entity(forEntityName: "Configure", in: GFDataService.context)
            let config = Configure(entity: entity!, insertInto: GFDataService.context)

            config.cappedThreshold = 10
            config.cappedDelay = 10
            config.bonusThreshold = 0
            config.bonusDelay = 0
            config.endOfTransitDay = 30
            config.cappedTicketId = 44
            config.bonusTicketid = 43
            
            let loyalty = GFLoyalty(config: config)

            beforeEach {
                
            }
            
            context("test endOfTransitTime", {
                it("should be", closure: {
                    let actual = loyalty.endOfTransitTime()
                    let expected = Int(Calendar.current.date(bySettingHour: 0, minute: 30, second: 0, of: Date())!.timeIntervalSince1970)
                    expect(actual).to(equal(expected))
                })
            })
            
            describe("test isProductEligibleForCappedRide", {
                
                let entity = NSEntityDescription.entity(forEntityName: "Product", in: GFDataService.context)
                let product = Product(entity: entity!, insertInto: GFDataService.context)

                context("when capped rides are disabled", {
                    beforeEach {
                        product.isCappedRideEnabled = 0
                    }
                    
                    it("should return false", closure: {
                        let actual = loyalty.isProductEligibleForCappedRide(product: product)
                        expect(actual).to(equal(false))
                    })
                })
                
                context("when cappedThreshold is not available", {
                    beforeEach {
                        product.cappedThreshold = 0
                    }
                    
                    it("should return false", closure: {
                        let actual = loyalty.isProductEligibleForCappedRide(product: product)
                        expect(actual).to(equal(false))
                    })
                })

                context("when taking a ride first time in a trnsit day", {
                    beforeEach {
                        product.cappedThreshold = 5
                        product.isCappedRideEnabled = 1
                    }
                    
                    it("should return false", closure: {
                        let actual = loyalty.isProductEligibleForCappedRide(product: product)
                        expect(actual).to(equal(false))
                    })
                })
            })
        }
    }
}
