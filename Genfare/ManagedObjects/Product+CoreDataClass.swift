//
//  Product+CoreDataClass.swift
//  Genfare
//
//  Created by vishnu on 25/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Product)
public class Product: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
