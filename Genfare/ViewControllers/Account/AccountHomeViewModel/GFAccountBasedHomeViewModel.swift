//
//  GFAccountBasedHomeViewModel.swift
//  Genfare
//
//  Created by vishnu on 29/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class GFAccountBasedHomeViewModel {
    
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    //let firstNameViewModel = NameTextViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    let balance : Variable<CGFloat> = Variable(0.0)
    let walletState : Variable<Bool> = Variable(true)
    let walletName : Variable<String> = Variable("-")
    
    func validateCredentials() -> Bool{
        return true;
    }

    func formErrorString() -> String {
        return ""
    }
    
    func refreshBalance() -> Void {
        isLoading.value = true
        
        GFAccountBalanceService.fetchAccountBalance { [unowned self] (success, error) in
            self.isLoading.value = false
            
            if success {
                //got account balance
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }
    
    func updateWalletStatus() {
        if let wallet = GFWalletsService.userWallet() {
            walletName.value = "\(wallet.nickname!) - \(wallet.status!)"
        }
    }
    
}
