//
//  GFPayGoPassViewModel.swift
//  Genfare
//
//  Created by vishnu on 01/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class GFPayGoPassViewModel {
    
    let disposebag = DisposeBag()
    var model:Array<Product> = []
    
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
        //fetchProducts()
        let products = GFFetchProductsService.getProducts()
        model = products.filter({ (product:Product) -> Bool in
            return product.ticketTypeDescription == "Stored Value"
        })
        isSuccess.value = true
    }
    
    func fetchProducts() {
        let products:GFFetchProductsService = GFFetchProductsService(walletID: GFWalletsService.walletID!)
        isLoading.value = true
        isSuccess.value = false

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

