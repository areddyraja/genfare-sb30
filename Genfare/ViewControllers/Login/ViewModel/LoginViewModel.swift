//
//  LoginViewModel.swift
//  Genfare
//
//  Created by vishnu on 20/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {
    
    let model : LoginModel = LoginModel()
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    let emailIdViewModel = EmailIdViewModel()
    let passwordViewModel = PasswordViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let walletNeeded : Variable<Bool> = Variable(false)
    let showWalletList: Variable<Array> = Variable([])
    let showRetrieveWallet: Variable<Bool> = Variable(false)
    let smsAuthNeeded: Variable<Bool> = Variable(false)
    let showAccountBased: Variable<Bool> = Variable(false)
    let showCardBased: Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    let logoutUser : Variable<Bool> = Variable(false)
    
    var walletJson:[String:Any]?
    
    func validateCredentials() -> Bool{
        return emailIdViewModel.validateCredentials() && passwordViewModel.validateCredentials();
    }
    
    func formErrorString() -> String {
        if(emailIdViewModel.errorValue.value != ""){
            return emailIdViewModel.errorValue.value ?? ""
        }else if(passwordViewModel.errorValue.value != ""){
            return passwordViewModel.errorValue.value ?? ""
        }
        
        return ""
    }

    func loginUser() {
        isLoading.value = true
        model.email = emailIdViewModel.data.value
        model.password = passwordViewModel.data.value

        let loginService = GFLoginService(username: model.email, password: model.password)
        loginService.loginUser { [unowned self] (success, error) in
            self.isLoading.value = false
            if success {
                self.refreshToken()
            }else{
                print(error)
                self.errorMsg.value = error as! String
            }
        }
    }
    
    func refreshToken(){
        isLoading.value = true
        
        GFRefreshAuthToken.refresh { [unowned self] (success, error) in
            self.isLoading.value = false

            if success {
                self.fetchWallets()
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }
    
    func fetchWallets(){
        isLoading.value = true

        let walletservice = GFCheckWalletService()
        walletservice.fetchWallets { [unowned self] (result, error) in
            self.isLoading.value = false
            if error == nil {
                self.checkForAssignedWallets(list: result as! Array)
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }
    
    func checkForAssignedWallets(list:Array<[String:Any]>){
        print(list)
        if list.count <= 0 {
            walletNeeded.value = true
            return
        }
        
        let cuuid = Utilities.deviceId()
        
        for (_,witem) in list.enumerated() {
            
            let item:[String:Any] = witem as! [String:Any]
            
            if let duuid = item["deviceUUID"] as? String, duuid == cuuid {
                GFWalletsService.saveWalletData(data: item)
                walletJson = item
                assignWallet()
                return
            }
            
            if let acctType = item["accountType"] as? String, acctType == "Card-Based" {
                if (item["deviceUUID"] as? String) != nil {
                    //show error
                    errorMsg.value = "Can not assign wallet to this device, as this is already assigned to a different device"
                    return
                }else{
                    walletJson = item
                    showRetrieveWallet.value = true
                    return
                }
            }
            
        }

       showWalletList.value = list.filter {($0["deviceUUID"] as? String) == nil}
        if( showWalletList.value.count == 0){
             walletNeeded.value = true
            return
        }

    }
    
    func walletRetrieved(value:Bool) {
        if value {
            GFWalletsService.saveWalletData(data: walletJson!)
            assignWallet()
        }else{
            logoutUser.value = true
        }
    }
    
    func assignWallet(){
        guard let waletid = walletJson!["id"] as? NSNumber else {
            fatalError("No wallet ID found to assign")
        }
        
        let assign = GFAssignWalletService(walletID: waletid)
        
        isLoading.value = true
        assign.assignWallet { [unowned self] (success, error) in
            self.isLoading.value = false

            if success {
                self.isSuccess.value = true
            }else{
                self.errorMsg.value = error as! String
            }
        }
    }
}
