//
//  Card+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 08/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData

extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var accountAuthToken: String?
    @NSManaged public var accountEmail: String?
    @NSManaged public var accountId: String?
    @NSManaged public var cardDescription: String?
    @NSManaged public var createdDateTime: NSDate?
    @NSManaged public var cvv: String?
    @NSManaged public var huuid: String?
    @NSManaged public var isTemporary: NSNumber?
    @NSManaged public var modifiedDateTime: NSDate?
    @NSManaged public var nickname: String?
    @NSManaged public var state: String?
    @NSManaged public var uuid: String?
    @NSManaged public var walletHuuid: String?
    @NSManaged public var walletUuid: String?

}
