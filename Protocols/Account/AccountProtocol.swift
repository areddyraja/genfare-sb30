//
//  AccountProtocol.swift
//  Genfare
//
//  Created by OmniTech on 18/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

protocol AccountProtocol {
    func currentAccount() -> Account?
    func configuredValues() -> Configure?
    func saveAccDetailsInKeychain(username:String,password:String,token:String)
}
extension AccountProtocol{
    func currentAccount() -> Account? {
        let records:Array<Account> = GFDataService.fetchRecords(entity: "Account") as! Array<Account>
        
        if records.count > 0 {
            return records.first
        }
        
        return nil
    }
    func configuredValues() -> Configure? {
        let records:Array<Configure> = GFDataService.fetchRecords(entity: "Configure") as! Array<Configure>
        
        if records.count > 0 {
            return records.first
        }
        
        return nil
    }
    func saveAccDetailsInKeychain(username:String,password:String,token:String) {
        KeychainWrapper.standard.set(username, forKey:Constants.KeyChain.UserName)
        KeychainWrapper.standard.set(password, forKey: Constants.KeyChain.Password)
        KeychainWrapper.standard.set(token, forKey: Constants.KeyChain.SecretKey)
    }
}
