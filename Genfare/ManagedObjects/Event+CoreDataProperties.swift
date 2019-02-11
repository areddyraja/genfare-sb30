//
//  Event+CoreDataProperties.swift
//  
//
//  Created by vishnu on 08/02/19.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var amountRemaining: NSNumber?
    @NSManaged public var clickedTime: NSNumber?
    @NSManaged public var fare: NSNumber?
    @NSManaged public var identifier: String?
    @NSManaged public var ticketActivationExpiryDate: String?
    @NSManaged public var ticketid: String?
    @NSManaged public var type: String?
    @NSManaged public var walletContentUsageIdentifier: String?

}
