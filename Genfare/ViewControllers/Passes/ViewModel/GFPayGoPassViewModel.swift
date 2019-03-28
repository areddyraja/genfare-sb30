//
//  GFPayGoPassViewModel.swift
//  Genfare
//
//  Created by vishnu on 01/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class GFPayGoPassViewModel {
    
    let disposebag = DisposeBag()
    var model:Array<Product> = []
    var walletmodelpayasyougo:WalletContents?
    
    // Initialise ViewModel's
    //let firstNameViewModel = NameTextViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    let barCode : Variable<Bool> = Variable(false)
    
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
    
    func confirmActivation(index:Int) {
        guard index < model.count else {
            fatalError("index out of bounds")
        }
        
        let product = model[index]
       walletmodelpayasyougo = insertProductIntoWallet(product: product)
        barCode.value = true
    }
    
    func insertProductIntoWallet(product:Product) -> WalletContents? {
        let managedContext = GFDataService.context
        let walletcontent = NSEntityDescription.entity(forEntityName: "WalletContents", in: managedContext)
        let walletObj:WalletContents = NSManagedObject(entity: walletcontent!, insertInto: managedContext) as! WalletContents
        let configure:Configure = GFAccountManager.configuredValues()!
        let wallet = GFWalletsService.userWallet()
        
        walletObj.fare = 0
        walletObj.ticketGroup = wallet!.accTicketGroupId
        
        walletObj.member = wallet!.accMemberId
        walletObj.purchasedDate = Int64(NSDate().timeIntervalSince1970 * 1000) as NSNumber
         walletObj.agencyId = configure.agencyId
        walletObj.descriptation = product.productDescription
        walletObj.type=product.ticketTypeId
        walletObj.ticketIdentifier = product.ticketId!.stringValue
        walletObj.allowInteraction = 1
        walletObj.designator = NSNumber.init( value: Int32(product.designator!)!)
        walletObj.identifier = String(format: "%@", product.ticketId!)//String(format: "%@$%lli", product.ticketId!, Date().toMillis())
        
        walletObj.instanceCount = 0;
        walletObj.status = "active"
        walletObj.purchasedDate = Int64(NSDate().timeIntervalSince1970 * 1000) as NSNumber
        walletObj.activationDate = Int64(NSDate().timeIntervalSince1970 * 1000) as NSNumber
        walletObj.generationDate = Int64(NSDate().timeIntervalSince1970 * 1000) as NSNumber
        walletObj.ticketEffectiveDate = Int64(NSDate().timeIntervalSince1970 * 1000) as NSNumber
        let cdate:Double = Date().timeIntervalSince1970
        walletObj.ticketActivationExpiryDate = (cdate + (product.barcodeTimer as! Double)) as NSNumber
        // walletObj.ticketSource=@"local";
        
        return walletObj
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

