//
//  Account+CoreDataProperties.swift
//  Genfare
//
//  Created by vishnu on 25/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var accountId: String?
    @NSManaged public var active: String?
    @NSManaged public var authToken: String?
    @NSManaged public var created: String?
    @NSManaged public var emailaddress: String?
    @NSManaged public var emailverified: NSNumber?
    @NSManaged public var farecode: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: NSNumber?
    @NSManaged public var isCurrent: NSNumber?
    @NSManaged public var isEmailVerified: NSNumber?
    @NSManaged public var isLoggedIn: NSNumber?
    @NSManaged public var lastlogin: String?
    @NSManaged public var lastName: String?
    @NSManaged public var lastupdated: String?
    @NSManaged public var loginDateTime: NSDate?
    @NSManaged public var mobilenumber: String?
    @NSManaged public var mobileverified: String?
    @NSManaged public var needs_additional_auth: NSNumber?
    @NSManaged public var notes: String?
    @NSManaged public var password: String?
    @NSManaged public var profileType: String?
    @NSManaged public var status: String?
    @NSManaged public var tokengenerated: String?
    @NSManaged public var uuid: String?
    @NSManaged public var walletname: String?

}
