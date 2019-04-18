//
//  GFAccountManager.swift
//  Genfare
//
//  Created by omniwzse on 03/10/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation

class GFAccountManager {
    
    init(){}
    
    static func logout() -> Void {
        KeychainWrapper.standard.removeAllKeys()
        
        GFDataService.deleteAllRecords(entity: "Account")
        GFDataService.deleteAllRecords(entity: "Wallet")
        GFDataService.deleteAllRecords(entity: "Product")
        GFDataService.deleteAllRecords(entity: "Ticket")
        GFDataService.deleteAllRecords(entity: "WalletActivity")
        GFDataService.deleteAllRecords(entity: "WalletContents")
        GFDataService.deleteAllRecords(entity: "LoyaltyCapped")
        GFDataService.deleteAllRecords(entity: "LoyaltyBonus")
    }
    
    static func saveToKeyChain(username:String,password:String,token:String) {
        KeychainWrapper.standard.set(username, forKey:Constants.KeyChain.UserName)
        KeychainWrapper.standard.set(password, forKey: Constants.KeyChain.Password)
        KeychainWrapper.standard.set(token, forKey: Constants.KeyChain.SecretKey)
    }
    
    static func currentAccount() -> Account? {
        let records:Array<Account> = GFDataService.fetchRecords(entity: "Account") as! Array<Account>
        
        if records.count > 0 {
            return records.first
        }
        
        return nil
    }
    
    static func configuredValues() -> Configure? {
        let records:Array<Configure> = GFDataService.fetchRecords(entity: "Configure") as! Array<Configure>
        
        if records.count > 0 {
            return records.first
        }
        
        return nil
    }

}
