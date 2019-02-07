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
    let smsAuthNeeded: Variable<Bool> = Variable(false)
    let showAccountBased: Variable<Bool> = Variable(false)
    let showCardBased: Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    
    var walletID:String?
    
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
    
    func checkForAssignedWallets(list:Array<Any>){
        if list.count <= 0 {
            walletNeeded.value = true
        }
        
        let cuuid = Utilities.deviceId()
        
        for (_,witem) in list.enumerated() {
            
            let item:[String:Any] = witem as! [String:Any]
            
            if let duuid = item["deviceUUID"] as? String, duuid == cuuid {
                GFWalletsService.saveWalletData(data: item)
                assignWallet(wid: item["id"] as! NSNumber)
                return
            }
        }
        showWalletList.value = list
    }
    
    func assignWallet(wid:NSNumber){
        let assign = GFAssignWalletService(walletID: wid)
        
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
