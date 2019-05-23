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

class GFAccountBasedHomeViewModel:WalletProtocol {
    
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    //let firstNameViewModel = NameTextViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    let balance : Variable<NSNumber> = Variable(0.0)
    let walletState : Variable<Bool> = Variable(true)
    let walletName : Variable<String> = Variable("-")
    let accountlandingmodel = GFAccountLandingViewModel()
    
    func validateCredentials() -> Bool{
        return true;
    }

    func formErrorString() -> String {
        return ""
    }
    
    func refreshBalance() -> Void {
        guard let userAccount:Account = GFAccountManager.currentAccount() else{ return }
        guard let accType = userAccount.profileType else { return }
        
        if accType == "CARD_BASED"{
            isLoading.value = false
//            let balance = Utilities.walletContentsBalance()
            self.balance.value = Utilities.walletContentsBalance()
        }else{
            self.isLoading.value = true
            guard NetworkManager.Reachability else {
                isLoading.value = false
                errorMsg.value = Constants.Message.NoNetwork
                self.balance.value = Utilities.accountBalance()
                return
            }
        
            GFAccountBalanceService.fetchAccountBalance { [unowned self] (success, error) in
                self.isLoading.value = false
                
                if success {
                    self.balance.value = Utilities.accountBalance()
                }else{     
                    self.errorMsg.value = "error"
                }
            }
        }

    }
    
    func updateWalletStatus() {
        if let wallet = self.userWallet() {
            walletName.value = "\(wallet.nickname!) - \(wallet.status!)"
        }
        refreshBalance()
    }
    func updateEventRecord(){
        accountlandingmodel.fireEvent()
    }
//    func getOfflineBalance(){
//        var offlineBalance = Utilities.walletContentsBalance()
//        let loyaltyData = GFLoyaltyData(product: product)
//        let loyalty = GFLoyaltyService(dataProvider: loyaltyData)
//
//        if loyalty.isProductEligibleForCappedRide() || loyalty.isProductEligibleForBonusRide() {
//
//            fare = 0
//        }
//        else{
//
//            fare = NumberFormatter().number(from: product.price!)!
//        }
//
//        if Utilities.isLoginCardBased(){
//            let productFare = NumberFormatter().number(from: product.price!)!
//            let remainingBal:Float = offlineBalance.floatValue - productFare.floatValue
//            offlineBalance = NSNumber.init(value: remainingBal)
//    }
//    }
}
