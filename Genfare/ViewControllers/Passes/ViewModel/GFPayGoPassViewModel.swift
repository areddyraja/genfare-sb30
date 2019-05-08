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

class GFPayGoPassViewModel:WalletProtocol {
    
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
            return product.ticketTypeDescription == "Stored Value" && product.isActivationOnly == 1
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
        let wallet = self.userWallet()
        
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
        let products:GFFetchProductsService = GFFetchProductsService(walletID: self.walledId())
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
    func updateWalletContentsBalance(selectedproduct:Product){
        let products = GFFetchProductsService.getProducts()
        let items = products.filter({ (product:Product) -> Bool in
            product.ticketTypeDescription == "Stored Value" && product.isActivationOnly == 0
        })
        if items.count > 0{
            if let prod = items[0] as? Product{
                if let ticketId = prod.ticketId?.intValue{
                    do{
                        var userObj:WalletContents
                        let managedContext = GFDataService.context
                        let fetchRequest:NSFetchRequest = WalletContents.fetchRequest()
                        let strTicketId = String(format: "%d", ticketId)
                        fetchRequest.predicate = NSPredicate(format: "ticketIdentifier == %@",strTicketId)
                        let fetchResults = try managedContext.fetch(fetchRequest)
                        if fetchResults.count >= 0 {
                            if let firstObj = fetchResults.first{
                                userObj = firstObj
                                var originalBalance:NSNumber
                                var productFare:NSNumber
                                if let bal =  firstObj.balance{
                                    originalBalance = NumberFormatter().number(from: bal)!
                                    if let price = selectedproduct.price{
                                        productFare = NumberFormatter().number(from: price)!
                                    }else{
                                        return
                                    }
                                    let remainingBal:Float = originalBalance.floatValue - productFare.floatValue
                                    userObj.balance = String(format: "%.2f",remainingBal)
                                    do {
                                        try managedContext.save()
                                    }catch _ as NSError {
                                        print("Error while updating walletcontnets")
                                    }
                                }else{ return }
                            }
                        }
                    }catch{
                        print("saving failed ")
                    }
                }
            }
        }
    }
    
}

