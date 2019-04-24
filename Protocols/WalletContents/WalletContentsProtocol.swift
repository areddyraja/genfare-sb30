//
//  WalletContentsProtocol.swift
//  Genfare
//
//  Created by OmniTech on 17/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

protocol WalletContentsProtocol {
    func isActive(walletcontents:WalletContents?) -> Bool
    func barcodestring(walletcontents:WalletContents?) -> String
}
extension WalletContentsProtocol{
    func isActive(walletcontents:WalletContents?) -> Bool{
        var isActiveTicket = false;
        if let walletcontent = walletcontents{
            let now = Date().timeIntervalSince1970
            if let expiryDate = walletcontent.ticketActivationExpiryDate {
                if Int64(truncating: expiryDate) > 0 && Int64(truncating: expiryDate) > Int64(now) {
                    isActiveTicket = true
                }
            }
        }
        return isActiveTicket
    }
    func barcodestring(walletcontents:WalletContents?) -> String{
        if let walletcontent = walletcontents{
            guard let account:Account = GFAccountManager.currentAccount() else{ return ""}
            guard let configure:Configure = GFAccountManager.configuredValues() else{ return ""}
            guard let transitId = Int(configure.transitId!) else { return ""}
            guard let ticketId = walletcontent.ticketIdentifier else{ return ""}
            if let prod = GFFetchProductsService.getProductFor(id: ticketId) {
                print(prod)
                let encString = BarcodeUtilities.generateBarcode(withTicket: walletcontents,
                                                                 product: prod,
                                                                 encriptionKey: GFEncryptionKeysService.getEncryptionKey()!,
                                                                 isFreeRide: false,
                                                                 deviceID: Utilities.deviceId(),
                                                                 transitID:NSNumber(value:transitId),
                                                                 accountId: account.accountId)
                return encString!
            }
        }
        
        return ""
    }
}


