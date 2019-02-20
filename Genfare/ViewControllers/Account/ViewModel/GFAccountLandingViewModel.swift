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
            updateAccountType()
        }
    }
    
    func fetchProducts() {
        let products:GFFetchProductsService = GFFetchProductsService(walletID: GFWalletsService.walletID!)
        isLoading.value = true

        products.getProducts { [unowned self] (success, error) in
            self.isLoading.value = false

            if success {
                print("Got Product contents successfully")
                self.getEncryptionKeys()
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }
    
    func getEncryptionKeys() {
        let encryptionkeys = GFEncryptionKeysService()
        encryptionkeys.fetchEncryptionKeys { (success, error) in
            if success {
                self.updateAccountType()
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }
    
    func updateAccountType() {
        let products = GFFetchProductsService.getProducts()
        let items = products.filter({ (product:Product) -> Bool in
            return product.ticketTypeDescription == "Stored Value"
        })
        if items.count > 0 {
            //show account based
            accountBased.value = true
        }else{
            //show card based
            cardBased.value = true
        }
    }
}
