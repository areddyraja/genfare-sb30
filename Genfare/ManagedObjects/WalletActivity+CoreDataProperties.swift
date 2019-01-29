//
//  WalletActivity+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 25/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData


extension WalletActivity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletActivity> {
        return NSFetchRequest<WalletActivity>(entityName: "WalletActivity")
    }

    @NSManaged public var activityId: NSNumber?
    @NSManaged public var activityTypeId: NSNumber?
    @NSManaged public var amountCharged: NSNumber?
    @NSManaged public var amountRemaining: NSNumber?
    @NSManaged public var date: NSNumber?
    @NSManaged public var event: String?
    @NSManaged public var ticketId: NSNumber?

}
