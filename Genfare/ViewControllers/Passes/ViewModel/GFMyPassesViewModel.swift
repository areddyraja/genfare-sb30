//
//  GFMyPassesViewModel.swift
//  Genfare
//
//  Created by vishnu on 04/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift
import CoreData



class GFMyPassesViewModel:WalletProtocol{
    
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
        
        let products:GFWalletContentsService = GFWalletContentsService(walletID: self.walledId())
        isLoading.value = true
        isSuccess.value = false

        products.getWalletContents { [unowned self] (success, error) in
            self.isLoading.value = false
            
            if success {
                print("Got Wallet contents successfully")
                self.model = self.filteredModel()
                self.isSuccess.value = true
                //self.fetchWalletContents()
            }else{
                 self.errorMsg.value = error as! String
            }
        }
    }
    
    func filteredModel() -> Array<WalletContents>{
        let filteredModel  = GFWalletContentsService.getContentsForDisplay()
        var expiryFilteredWalletContent:Array<WalletContents> = []
             expiryFilteredWalletContent.removeAll()
        if (filteredModel.count > 0){
            let now = Date().timeIntervalSince1970
            for i in filteredModel{
                if let expiryDate = i.ticketActivationExpiryDate {

                    if  (Int64(truncating: expiryDate) < Int64(now) && (i.type == "1")){ //Here 1 is stored value

                        GFDataService.deletePayAsYouGoWallet(entity: "WalletContents",wallet: i)
                    }
                    else{
                        expiryFilteredWalletContent.append(i)
                    }
                    

                }
            }
            //  filtere
        }
        expiryFilteredWalletContent = expiryFilteredWalletContent.sorted(by: { $0.activationDate!.intValue > $1.activationDate!.intValue } )
        
        // self.isLoading.value = false
        return expiryFilteredWalletContent
        
    }
    
    private static func removeInvalidContents() {
        let managedContext = GFDataService.context
        do {
            let fetchRequest:NSFetchRequest = WalletContents.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "ticketIdentifier == nil")
            let fetchResults = try managedContext.fetch(fetchRequest)
            for item in fetchResults{
                managedContext.delete(item)
            }
            GFDataService.saveContext()
        }catch{
            print("Update failed")
        }
    }
}

