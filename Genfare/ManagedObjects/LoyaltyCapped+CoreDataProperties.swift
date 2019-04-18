//
//  LoyaltyCapped+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 17/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData


extension LoyaltyCapped {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoyaltyCapped> {
        return NSFetchRequest<LoyaltyCapped>(entityName: "LoyaltyCapped")
    }

    @NSManaged public var activatedTime: NSNumber?
    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var referenceActivatedTime: NSNumber?
    @NSManaged public var rideCount: NSNumber?
    @NSManaged public var ticketId: NSNumber?
    @NSManaged public var walletId: String?

}
