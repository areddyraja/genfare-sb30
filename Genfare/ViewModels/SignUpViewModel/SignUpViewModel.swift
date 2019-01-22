//
//  SignUpViewModel.swift
//  Genfare
//
//  Created by vishnu on 21/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class SignUpViewModel {
    
    let model : SignUpModel = SignUpModel()
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    let firstNameViewModel = NameTextViewModel()
    let lastNameViewModel = NameTextViewModel()
    let emailIdViewModel = EmailIdViewModel()
    let passwordViewModel = PasswordViewModel()
    let passwordViewModel2 = PasswordViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    
    func validateCredentials() -> Bool{
        return firstNameViewModel.validateCredentials() && lastNameViewModel.validateCredentials() && emailIdViewModel.validateCredentials() && passwordViewModel.validateCredentials() && matchPasswords();
    }
    
    func formErrorString() -> String {
        
        if firstNameViewModel.errorValue.value != "" {
            return firstNameViewModel.errorValue.value ?? ""
        }else if(lastNameViewModel.errorValue.value != ""){
            return lastNameViewModel.errorValue.value ?? ""
        }else if(emailIdViewModel.errorValue.value != ""){
            return emailIdViewModel.errorValue.value ?? ""
        }else if(passwordViewModel.errorValue.value != ""){
            return passwordViewModel.errorValue.value ?? ""
        }else if(!matchPasswords()){
            return "Passwords does not match"
        }
        
        return ""
    }
    
    func matchPasswords() -> Bool {
        return passwordViewModel2.data.value == passwordViewModel.data.value
    }
    
    func signUpUser(completionHandler:@escaping (_ result:Any?,_ error:Any?) -> Void){
        
        // Initialise model with filed values
        model.firstName = firstNameViewModel.data.value
        model.lastName = lastNameViewModel.data.value
        model.email = emailIdViewModel.data.value
        model.password = passwordViewModel.data.value
        
        self.isLoading.value = true
        
        // launch request
        let registerURL = "/services/data-api/mobile/users?tenant=BCT"
        let fullURL = String(format: "%@%@", Utilities.apiURL(),registerURL)
        
        let headers:HTTPHeaders = ["Authorization":String(format: "bearer %@", Utilities.accessToken()),
                                   "Accept":"application/json",
                                   "Content-Type":"application/json",
                                   "app_version":"5.2",
                                   "app_os":"ios",
                                   "DeviceId":"02e1c84df688a47c"]
        
        let parameters:[String:String] = ["emailaddress":model.email,
                                          "password":model.password,
                                          "firstname":model.firstName,
                                          "lastname":model.lastName]
        
        Alamofire.request(fullURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                    let dict = JSON as? [String:AnyObject]
                    let success:Bool = dict!["success"] as! Bool
                    if(!success){
                        completionHandler(JSON,dict?["message"])
                    }else{
                        completionHandler(JSON,nil)
                    }

                case .failure(let error):
                    completionHandler(nil,error.localizedDescription)
                    print("Request failed with error: \(error)")
                }
        }
    }
}
