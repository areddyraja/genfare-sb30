//
//  Wallet+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 25/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData


extension Wallet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wallet> {
        return NSFetchRequest<Wallet>(entityName: "Wallet")
    }

    @NSManaged public var accountType: String?
    @NSManaged public var cardType: String?
    @NSManaged public var createdDateTime: NSDate?
    @NSManaged public var cvv: String?
    @NSManaged public var deviceUUID: String?
    @NSManaged public var farecode_expiry: NSNumber?
    @NSManaged public var huuid: String?
    @NSManaged public var id: NSNumber?
    @NSManaged public var modifiedDateTime: NSDate?
    @NSManaged public var nickname: String?
    @NSManaged public var personId: NSNumber?
    @NSManaged public var state: String?
    @NSManaged public var status: String?
    @NSManaged public var statusId: NSNumber?
    @NSManaged public var uuid: String?
    @NSManaged public var walletDescription: String?
    @NSManaged public var walletUUID: String?
    @NSManaged public var accMemberId: String?
    @NSManaged public var accTicketGroupId: String?
    @NSManaged public var farecode: NSNumber?
    @NSManaged public var walletId: NSNumber?
    @NSManaged public var printedId: String?

}
