//
//  GFActivityViewModel.swift
//  Genfare
//
//  Created by vishnu on 05/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class GFActivityViewModel:WalletProtocol{
    
    let disposebag = DisposeBag()
    var model:Array<WalletActivity> = []
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    
    func formErrorString() -> String {
        return ""
    }
    
    func showActivity() {
        model = GFWalletActivityService.getHistory()
        //        model = products.filter({ (product:Product) -> Bool in
        //            return product.ticketTypeDescription == "Stored Value"
        //        })
        isSuccess.value = true
    }
    
    func fetchWalletActivity() {
        let history:GFWalletActivityService = GFWalletActivityService(walletID: self.walledId())
        isLoading.value = true
        isSuccess.value = false
        
        history.fetchHistory { [unowned self] (success, error) in
            self.isLoading.value = false
            
            if success {
                print("Got Wallet Activity successfully")
                self.isSuccess.value = true
                //self.fetchWalletContents()
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }
}

