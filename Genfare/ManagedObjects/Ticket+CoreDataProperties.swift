//
//  Ticket+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 25/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData


extension Ticket {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ticket> {
        return NSFetchRequest<Ticket>(entityName: "Ticket")
    }

    @NSManaged public var activatedSeconds: NSNumber?
    @NSManaged public var activationCount: NSNumber?
    @NSManaged public var activationCountMax: NSNumber?
    @NSManaged public var activationDateTime: NSNumber?
    @NSManaged public var activationLiveTime: NSNumber?
    @NSManaged public var activationResetTime: NSNumber?
    @NSManaged public var activationTransitionTime: NSNumber?
    @NSManaged public var activationType: String?
    @NSManaged public var arrivalStation: NSNumber?
    @NSManaged public var arriveId: String?
    @NSManaged public var arriveStationId: String?
    @NSManaged public var bfp: String?
    @NSManaged public var creditCard: String?
    @NSManaged public var departId: String?
    @NSManaged public var departStationId: String?
    @NSManaged public var departureStation: NSNumber?
    @NSManaged public var deviceId: String?
    @NSManaged public var eventLat: NSNumber?
    @NSManaged public var eventLng: NSNumber?
    @NSManaged public var eventType: String?
    @NSManaged public var expirationDateTime: NSNumber?
    @NSManaged public var expirationSpan: NSNumber?
    @NSManaged public var fareCode: String?
    @NSManaged public var fareZoneCode: String?
    @NSManaged public var fareZoneCodeDesc: String?
    @NSManaged public var firstActivationDateTime: NSNumber?
    @NSManaged public var firstName: String?
    @NSManaged public var id: String?
    @NSManaged public var inspections: NSNumber?
    @NSManaged public var invoiceId: String?
    @NSManaged public var isAdjustedForDst: NSNumber?
    @NSManaged public var isCurrent: NSNumber?
    @NSManaged public var isHistory: NSNumber?
    @NSManaged public var isStaging: NSNumber?
    @NSManaged public var isStoredValue: NSNumber?
    @NSManaged public var lastName: String?
    @NSManaged public var lastUpdated: NSNumber?
    @NSManaged public var memberId: String?
    @NSManaged public var purchaseDateTime: NSNumber?
    @NSManaged public var riderCount: NSNumber?
    @NSManaged public var riderTypeCode: String?
    @NSManaged public var riderTypeDesc: String?
    @NSManaged public var sellerId: String?
    @NSManaged public var serviceCode: String?
    @NSManaged public var status: String?
    @NSManaged public var statusCode: NSNumber?
    @NSManaged public var szType: String?
    @NSManaged public var ticketAmount: NSNumber?
    @NSManaged public var ticketGroupId: String?
    @NSManaged public var ticketTypeCode: String?
    @NSManaged public var ticketTypeDesc: String?
    @NSManaged public var ticketTypeNote: String?
    @NSManaged public var transitId: String?
    @NSManaged public var type: String?
    @NSManaged public var validStartDateTime: NSNumber?

}
