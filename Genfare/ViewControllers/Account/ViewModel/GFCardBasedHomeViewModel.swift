//
//  GFCardBasedAccountViewModel.swift
//  Genfare
//
//  Created by vishnu on 29/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class GFCardBasedHomeViewModel:WalletProtocol {
    
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    let walletState : Variable<Bool> = Variable(true)
    let walletName : Variable<String> = Variable("-")
    
    func validateCredentials() -> Bool{
        return true;
    }
    
    func formErrorString() -> String {
        return ""
    }
    
    func updateWalletStatus() {
        if let wallet = self.userWallet() {
            walletName.value = "\(wallet.nickname!) - \(wallet.status!)"
        }
    }
}

