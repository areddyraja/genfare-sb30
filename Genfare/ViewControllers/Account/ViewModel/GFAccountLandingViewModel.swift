//
//  GFAccountLandingViewModel.swift
//  Genfare
//
//  Created by vishnu on 01/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class GFAccountLandingViewModel {
    
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    //let firstNameViewModel = NameTextViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    let accountBased : Variable<Bool> = Variable(false)
    let cardBased : Variable<Bool> = Variable(false)
    
    func formErrorString() -> String {
        return ""
    }

    func checkWalletStatus() {
        if NetworkManager.Reachability {
            fetchProducts()
        }else{
            isSuccess.value = true
        }
    }
    
    func fetchProducts() {
        let products:GFFetchProductsService = GFFetchProductsService(walletID: GFWalletsService.walletID!)
        isLoading.value = true

        products.getProducts { [unowned self] (success, error) in
            self.isLoading.value = false

            if success {
                print("Got Product contents successfully")
                self.isSuccess.value = true
                //self.fetchWalletContents()
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }
}
