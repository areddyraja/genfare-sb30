//
//  GFCreateWalletViewModel.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CreateWalletViewModel {
    
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    let walletNameViewModel = NameTextViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    
    func validateCredentials() -> Bool{
        return walletNameViewModel.validateCredentials()
    }

    func formErrorString() -> String {
        if walletNameViewModel.errorValue.value != "" {
            return walletNameViewModel.errorValue.value ?? ""
        }
        return ""
    }

    func createWallet(){
        let createWalletService = GFCreateWalletService(nickname:walletNameViewModel.data.value)
        createWalletService.createWallet(completionHandler: {[weak self] (success, error) in
            if success {
                self?.isSuccess.value = true
            }else{
                self?.errorMsg.value = error as! String
            }
        })
    }
}
