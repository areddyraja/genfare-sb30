//
//  GFWalletService.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFWalletsService {
    
    init(){}
    
    static func saveWalletData(data:[String:Any]) {
        GFDataService.deleteAllRecords(entity: "Wallet")
        
        let managedContext = GFDataService.context
        let wallet = NSEntityDescription.entity(forEntityName: "Wallet", in: managedContext)
        let userObj:Wallet = NSManagedObject(entity: wallet!, insertInto: managedContext) as! Wallet
        
        userObj.accMemberId = data["accMemberId"] as? String
        userObj.accTicketGroupId = data["accTicketGroupId"] as? String
        userObj.accountType = data["accountType"] as? String
        userObj.cardType = data["cardType"] as? String
        userObj.deviceUUID = data["deviceUUID"] as? String
        userObj.farecode = data["farecode"] as? NSNumber
        userObj.farecode_expiry = data["farecode_expiry"] as? NSNumber
        userObj.id = data["id"] as? NSNumber
        userObj.nickname = data["nickname"] as? String
        userObj.personId = data["personId"] as? NSNumber
        userObj.status = data["status"] as? String
        userObj.statusId = data["statusId"] as? NSNumber
        userObj.walletId = data["walletId"] as? NSNumber
        userObj.walletUUID = data["walletUUID"] as? String
        
        GFDataService.saveContext()
    }
    
    static func parseWallet(data:[String:Any]) -> Wallet {
        let userObj:Wallet = Wallet(context: GFDataService.context)
        
        userObj.accMemberId = data["accMemberId"] as? String
        userObj.accTicketGroupId = data["accTicketGroupId"] as? String
        userObj.accountType = data["accountType"] as? String
        userObj.cardType = data["cardType"] as? String
        userObj.deviceUUID = data["deviceUUID"] as? String
        userObj.farecode = data["farecode"] as? NSNumber
        userObj.farecode_expiry = data["farecode_expiry"] as? NSNumber
        userObj.id = data["id"] as? NSNumber
        userObj.nickname = data["nickname"] as? String
        userObj.personId = data["personId"] as? NSNumber
        userObj.status = data["status"] as? String
        userObj.statusId = data["statusId"] as? NSNumber
        userObj.walletId = data["walletId"] as? NSNumber
        userObj.walletUUID = data["walletUUID"] as? String

        return userObj
    }
    
//    static var walletID:NSNumber? {
//        let wallet = userWallet()
//        return wallet?.walletId
//    }
//    
//    static func userWallet() -> Wallet? {
//        let records:Array<Wallet> = GFDataService.fetchRecords(entity: "Wallet") as! Array<Wallet>
//        
//        if records.count > 0 {
//            return records.first
//        }
//        
//        return nil
//    }
//    
//    static func isWalletAvailable() -> Bool {
//        if userWallet() != nil {
//            return true
//        }else{
//            return false
//        }
//    }
}


