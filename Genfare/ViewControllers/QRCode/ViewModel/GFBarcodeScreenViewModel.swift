//
//  GFBarcodeScreenViewModel.swift
//  Genfare
//
//  Created by vishnu on 11/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation

class GFBarcodeScreenViewModel:GFBaseViewModel {
    
    var walletModel:WalletContents = WalletContents(context: GFDataService.context)
    
    func barcodeString() -> String {
        let account:Account = GFAccountManager.currentAccount()!
        if let prod = GFFetchProductsService.getProductFor(id: walletModel.ticketIdentifier!) {
            print(prod)
            let encString = BarcodeUtilities.generateBarcode(withTicket: walletModel,
                                                             product: prod,
                                                             encriptionKey: GFEncryptionKeysService.getEncryptionKey()!,
                                                             isFreeRide: false,
                                                             deviceID: Utilities.deviceId(),
                                                             transitID: Utilities.transitID(),
                                                             accountId: account.accountId)
            return encString!
        }
        
        return ""
    }
    
}
