//
//  EncryptionSet+CoreDataProperties.swift
//  
//
//  Created by vishnu on 08/02/19.
//
//

import Foundation
import CoreData


extension EncryptionSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EncryptionSet> {
        return NSFetchRequest<EncryptionSet>(entityName: "EncryptionSet")
    }

    @NSManaged public var currentKey: NSNumber?
    @NSManaged public var disableTimestamp: NSNumber?
    @NSManaged public var enabled: NSNumber?
    @NSManaged public var enabledTimestamp: NSNumber?
    @NSManaged public var idNum: NSNumber?
    @NSManaged public var keyType: String?
    @NSManaged public var primaryData: String?
    @NSManaged public var secondaryData: String?

}
