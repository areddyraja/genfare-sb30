//
//  LoginViewModel.swift
//  Genfare
//
//  Created by vishnu on 20/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class LoginViewModel {
    
    let model : SigninModel = SigninModel()
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

    func loginUser(completionHandler:@escaping (_ result:Any?,_ error:Any?) -> Void){
        
        // Initialise model with filed values
        model.email = emailIdViewModel.data.value
        model.password = passwordViewModel.data.value
        
        self.isLoading.value = true
        
        // launch request
        let loginURL = "/services/data-api/mobile/login?tenant=BCT"
        let fullURL = String(format: "%@%@", Utilities.apiURL(),loginURL)
        
        let headers:HTTPHeaders = ["Authorization":String(format: "bearer %@", Utilities.accessToken()),
                                   "Accept":"application/json",
                                   "Content-Type":"application/json",
                                   "app_version":"5.2",
                                   "app_os":"ios",
                                   "DeviceId":"02e1c84df688a47c"]
        
        let parameters:[String:String] = ["deviceUUid":"02e1c84df688a47c",
                                          "emailaddress":model.email,
                                          "password":model.password]
        
        Alamofire.request(fullURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    self.isLoading.value = false
                    self.isSuccess.value = true
                    let dict = JSON as? [String:AnyObject]
                    let success:Bool = dict!["success"] as! Bool
                    if(!success){
                        completionHandler(JSON,dict?["message"])
                    }else{
                        completionHandler(JSON,nil)
                    }
                    print(JSON)
                //self.refreshToken(username: username, password: password)
                case .failure(let error):
                    self.isLoading.value = false
                    self.errorMsg.value = error.localizedDescription
                    completionHandler(nil,error)
                }
        }
    }
}
