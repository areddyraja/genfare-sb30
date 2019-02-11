//
//  AccountSettingViewModel.swift
//  Genfare
//
//  Created by omniwyse on 08/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import  RxSwift

class AccountSettingViewModel{
    let model : AccountSettingsModel = AccountSettingsModel()
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    let emailIdViewModel = EmailIdViewModel()
    let passwordViewModel = PasswordViewModel()
    let passwordViewModel2 = PasswordViewModel()
    let passwordViewModel3 = PasswordViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    
    var walletID:String?
    
    func validateCredentials() -> Bool{
        return emailIdViewModel.validateCredentials() && passwordViewModel.validateCredentials() && matchWithCurrentPasswordEmail();
    }
    
    func matchWithCurrentPasswordEmail() -> Bool {
        //let account:Account = GFDataService.currentAccount()!
        let existingPassword = String(describing: KeychainWrapper.standard.string(forKey: Constants.KeyChain.Password)!)
        return passwordViewModel.data.value == existingPassword
    }
    
    func validateCredentialsForPassword() -> Bool{
        return   passwordViewModel.validateCredentials() && matchPasswords() && matchWithCurrentPasswords();
    }
    
    func matchPasswords() -> Bool {
        return passwordViewModel3.data.value == passwordViewModel.data.value
    }
    
    func matchWithCurrentPasswords() -> Bool {
         //let account:Account = GFDataService.currentAccount()!
        let existingPassword = String(describing: KeychainWrapper.standard.string(forKey: Constants.KeyChain.Password)!)
        return passwordViewModel2.data.value == existingPassword
    }
    
    func formErrorString() -> String {
        if(emailIdViewModel.errorValue.value != ""){
            return emailIdViewModel.errorValue.value ?? ""
        }else if(passwordViewModel.errorValue.value != ""){
            return passwordViewModel.errorValue.value ?? ""
        }
        
        return ""
    }
    func formErrorPasswordString() -> String {
        if(passwordViewModel.errorValue.value != ""){
            return passwordViewModel.errorValue.value ?? ""
        }
        
        return ""
    }
    
    func changeUser() {
        isLoading.value = true
        
        let changeuser:GFChangeAccountService = GFChangeAccountService(email: emailIdViewModel.data.value, password: passwordViewModel.data.value)
        changeuser.changeUserParameter { [weak self] (success, error) in
            self!.isLoading.value = false
            if success {
                print ("sucess")
            }else{
                print(error)
                self!.errorMsg.value = error as! String
            }
        }
  }
    func changePasswordForUser() {
        isLoading.value = true
        let email = (String(describing: KeychainWrapper.standard.string(forKey: Constants.KeyChain.UserName)!))
        let changeuser:GFChangeAccountService = GFChangeAccountService(email: email, password: passwordViewModel.data.value)
        changeuser.changeUserParameter { [unowned self] (success, error) in
            self.isLoading.value = false
            if success {
                print ("sucess")
            }else{
                print(error)
                self.errorMsg.value = error as! String
            }
        }
    }
}
