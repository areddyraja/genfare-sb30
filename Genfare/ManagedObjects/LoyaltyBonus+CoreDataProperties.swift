//
//  LoyaltyBonus+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 17/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData


extension LoyaltyBonus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoyaltyBonus> {
        return NSFetchRequest<LoyaltyBonus>(entityName: "LoyaltyBonus")
    }

    @NSManaged public var activatedTime: NSNumber?
    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var referenceActivatedTime: NSNumber?
    @NSManaged public var rideCount: NSNumber?
    @NSManaged public var ticketId: NSNumber?
    @NSManaged public var walletId: String?

}
