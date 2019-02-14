//
//  GFAccountInfoViewModel.swift
//  Genfare
//
//  Created by vishnu on 07/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class GFAccountInfoViewModel {
    
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    //let firstNameViewModel = NameTextViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    let logoutUser : Variable<Bool> = Variable(false)
    
    func formErrorString() -> String {
        return ""
    }
    
    func transferCard() {
        guard NetworkManager.Reachability else {
            isLoading.value = false
            errorMsg.value = Constants.Message.NoNetwork
            return
        }
        
        let configValues = GFReleaseWalletService(walletID: GFWalletsService.walletID!)
        isLoading.value = true

        configValues.releaseWallet { [unowned self] (success,error) in
            self.isLoading.value = false

            if success {
                self.logoutUser.value = true
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }

}
