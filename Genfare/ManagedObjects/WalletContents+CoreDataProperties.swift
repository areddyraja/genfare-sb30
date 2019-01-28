//
//  WalletContents+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 25/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData


extension WalletContents {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletContents> {
        return NSFetchRequest<WalletContents>(entityName: "WalletContents")
    }

    @NSManaged public var activationCount: NSNumber?
    @NSManaged public var activationDate: NSNumber?
    @NSManaged public var agencyId: NSNumber?
    @NSManaged public var allowInteraction: NSNumber?
    @NSManaged public var balance: String?
    @NSManaged public var descriptation: String?
    @NSManaged public var designator: NSNumber?
    @NSManaged public var expirationDate: String?
    @NSManaged public var fare: NSNumber?
    @NSManaged public var generationDate: NSNumber?
    @NSManaged public var group: String?
    @NSManaged public var identifier: String?
    @NSManaged public var instanceCount: NSNumber?
    @NSManaged public var member: String?
    @NSManaged public var purchasedDate: NSNumber?
    @NSManaged public var slot: NSNumber?
    @NSManaged public var status: String?
    @NSManaged public var ticketActivationExpiryDate: NSNumber?
    @NSManaged public var ticketEffectiveDate: NSNumber?
    @NSManaged public var ticketExpiryDate: NSNumber?
    @NSManaged public var ticketGroup: String?
    @NSManaged public var ticketIdentifier: String?
    @NSManaged public var ticketSource: String?
    @NSManaged public var type: String?
    @NSManaged public var valueOriginal: NSNumber?
    @NSManaged public var valueRemaining: NSNumber?

}
