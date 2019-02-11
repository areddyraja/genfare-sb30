//
//  CardEvent+CoreDataProperties.swift
//  
//
//  Created by vishnu on 08/02/19.
//
//

import Foundation
import CoreData


extension CardEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardEvent> {
        return NSFetchRequest<CardEvent>(entityName: "CardEvent")
    }

    @NSManaged public var code: NSNumber?
    @NSManaged public var content: NSData?
    @NSManaged public var detail: String?
    @NSManaged public var occurredOnDateTime: NSDate?
    @NSManaged public var position: NSData?
    @NSManaged public var type: String?

}
