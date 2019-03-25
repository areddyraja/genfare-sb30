//
//  StoredAddress+CoreDataProperties.swift
//  
//
//  Created by omniwyse on 21/03/19.
//
//

import Foundation
import CoreData


extension StoredAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredAddress> {
        return NSFetchRequest<StoredAddress>(entityName: "StoredAddress")
    }

    @NSManaged public var isoCountryCode: String?
    @NSManaged public var latitude: String?
    @NSManaged public var locality: String?
    @NSManaged public var longitude: String?
    @NSManaged public var name: String?
    @NSManaged public var subThoroughfare: String?
    @NSManaged public var thoroughfare: String?
    @NSManaged public var type: String?

}
