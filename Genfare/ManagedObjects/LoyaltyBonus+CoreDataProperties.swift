//
//  LoyaltyBonus+CoreDataProperties.swift
//  
//
//  Created by vishnu on 08/02/19.
//
//

import Foundation
import CoreData


extension LoyaltyBonus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoyaltyBonus> {
        return NSFetchRequest<LoyaltyBonus>(entityName: "LoyaltyBonus")
    }

    @NSManaged public var activatedTime: NSDate?
    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var referenceActivatedTime: NSDate?
    @NSManaged public var rideCount: NSNumber?
    @NSManaged public var ticketId: NSNumber?
    @NSManaged public var walletId: String?

}
