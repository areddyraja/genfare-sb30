//
//  EncryptionKey+CoreDataProperties.swift
//  
//
//  Created by vishnu on 08/02/19.
//
//

import Foundation
import CoreData


extension EncryptionKey {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EncryptionKey> {
        return NSFetchRequest<EncryptionKey>(entityName: "EncryptionKey")
    }

    @NSManaged public var algorithm: String?
    @NSManaged public var initializationVector: String?
    @NSManaged public var keyId: String?
    @NSManaged public var secretKey: String?

}
