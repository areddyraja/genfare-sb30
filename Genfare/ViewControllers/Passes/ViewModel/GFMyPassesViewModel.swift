//
//  GFMyPassesViewModel.swift
//  Genfare
//
//  Created by vishnu on 04/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class GFMyPassesViewModel {
    
    let disposebag = DisposeBag()
    var model:Array<WalletContents> = []
    
    // Initialise ViewModel's
    //let firstNameViewModel = NameTextViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    
    func formErrorString() -> String {
        return ""
    }
    
    func showProducts() {
        model = GFWalletContentsService.getContentsForDisplay()
        isSuccess.value = true
    }
    
    func fetchWalletContents() {
        guard NetworkManager.Reachability else {
            errorMsg.value = Constants.Message.NoNetwork
            isSuccess.value = true
            return
        }
        
        let products:GFWalletContentsService = GFWalletContentsService(walletID: GFWalletsService.walletID!)
        isLoading.value = true
        isSuccess.value = false

        products.getWalletContents { [unowned self] (success, error) in
            self.isLoading.value = false
            
            if success {
                print("Got Wallet contents successfully")
                self.model = GFWalletContentsService.getContentsForDisplay()
                self.isSuccess.value = true
                //self.fetchWalletContents()
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }
}

