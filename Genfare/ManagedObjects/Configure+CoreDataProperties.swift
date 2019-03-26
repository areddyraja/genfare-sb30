//
//  Configure+CoreDataProperties.swift
//  
//
//  Created by omniwyse on 26/03/19.
//
//

import Foundation
import CoreData


extension Configure {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Configure> {
        return NSFetchRequest<Configure>(entityName: "Configure")
    }

    @NSManaged public var agencyContactNumber: NSNumber?
    @NSManaged public var agencyId: NSNumber?
    @NSManaged public var barcodeActivationOffSetInMins: NSNumber?
    @NSManaged public var bonusDelay: NSNumber?
    @NSManaged public var bonusFarecode: String?
    @NSManaged public var bonusThreshold: NSNumber?
    @NSManaged public var bonusTicketid: NSNumber?
    @NSManaged public var cappedDelay: NSNumber?
    @NSManaged public var cappedFarecode: String?
    @NSManaged public var cappedThreshold: NSNumber?
    @NSManaged public var cappedTicketId: NSNumber?
    @NSManaged public var configMax: NSNumber?
    @NSManaged public var configMin: NSNumber?
    @NSManaged public var endOfTransitDay: NSNumber?
    @NSManaged public var key12: String?
    @NSManaged public var transitId: NSNumber?

}
