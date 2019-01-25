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
    let errorMsg : Variable<String> = Variable("")
    
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

}
