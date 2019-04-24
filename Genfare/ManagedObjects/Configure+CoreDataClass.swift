//
//  Configure+CoreDataClass.swift
//  
//
//  Created by omniwyse on 26/03/19.
//
//

import Foundation
import CoreData


public class Configure: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
