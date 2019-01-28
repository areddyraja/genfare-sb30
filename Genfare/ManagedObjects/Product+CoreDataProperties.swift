//
//  Product+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 25/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var barcodeTimer: NSNumber?
    @NSManaged public var bonusThreshold: NSNumber?
    @NSManaged public var cappedThreshold: NSNumber?
    @NSManaged public var designator: String?
    @NSManaged public var displayOrder: NSNumber?
    @NSManaged public var fareCode: String?
    @NSManaged public var isActivationOnly: NSNumber?
    @NSManaged public var isBonusRideEnabled: NSNumber?
    @NSManaged public var isCappedRideEnabled: NSNumber?
    @NSManaged public var offeringId: NSNumber?
    @NSManaged public var price: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var productId: NSNumber?
    @NSManaged public var ticketId: NSNumber?
    @NSManaged public var ticketSubTypeId: String?
    @NSManaged public var ticketTypeDescription: String?
    @NSManaged public var ticketTypeId: String?

}
