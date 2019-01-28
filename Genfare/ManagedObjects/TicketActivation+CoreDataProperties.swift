//
//  TicketActivation+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 25/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData


extension TicketActivation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TicketActivation> {
        return NSFetchRequest<TicketActivation>(entityName: "TicketActivation")
    }

    @NSManaged public var activationDate: String?
    @NSManaged public var activationExpDate: String?
    @NSManaged public var ticketIdentifier: String?

}
