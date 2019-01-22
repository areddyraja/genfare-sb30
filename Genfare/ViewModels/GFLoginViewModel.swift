//
//  LoginViewModel.swift
//  Genfare
//
//  Created by vishnu on 08/01/19.
//  Copyright © 2019 Genfare. All rights reserved.
//

import Foundation
import RxSwift
import NetworkStack
import Alamofire

class GFSigninViewModel  {
    
    let model: SigninModel
    private let disposeBag = DisposeBag()
    
    let emailFieldViewModel = GFEmailViewModel()
    let passwordFieldViewModel = GFPasswordViewModel()
    
    // RX
    let isLoading = Variable(false)
    var isSuccess = Variable(false)
    var errorMessage = Variable<String?>(nil)
    
    init(model: SigninModel) {
        self.model = model
    }
    
    func validForm() -> Bool {
        return emailFieldViewModel.validate() && passwordFieldViewModel.validate()
    }
    
    func signin() {
        // update model
        model.email     = emailFieldViewModel.value.value
        model.password  = passwordFieldViewModel.value.value
        
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
                    print(JSON)
                    //self.refreshToken(username: username, password: password)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
   
    func updateClient () {
        
    }
}

struct GFEmailViewModel : GFFieldViewModel {
    
    var value: Variable<String> = Variable("")
    var errorValue: Variable<String?> = Variable(nil)
    
    let title = "Email"
    let errorMessage = "Email is wrong"
    
    func validate() -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@([A-Za-z0-9.-]{2,64})+\\.[A-Za-z]{2,64}"
        guard validateString(value.value, pattern:emailPattern) else {
            errorValue.value = errorMessage
            return false
        }
        errorValue.value = nil
        return true
    }
}

struct GFPasswordViewModel : GFFieldViewModel, GFSecureFieldViewModel {
    
    var value: Variable<String> = Variable("")
    var errorValue: Variable<String?> = Variable(nil)
    
    let title = "Password"
    let errorMessage = "Wrong password !"
    
    var isSecureTextEntry: Bool = true
    
    func validate() -> Bool {
        // between 8 and 25 caracters
        guard validateSize(value.value, size: (8,25)) else {
            errorValue.value = errorMessage
            return false
        }
        errorValue.value = nil
        return true
    }
}

// Options for FieldViewModel
protocol GFSecureFieldViewModel {
    var isSecureTextEntry: Bool { get }
}

protocol GFFieldViewModel {
    var title: String { get}
    var errorMessage: String { get }
    
    // Observables
    var value: Variable<String> { get set }
    var errorValue: Variable<String?> { get}
    
    // Validation
    func validate() -> Bool
}

extension GFFieldViewModel {
    func validateSize(_ value: String, size: (min:Int, max:Int)) -> Bool {
        return (size.min...size.max).contains(value.count)
    }
    func validateString(_ value: String?, pattern: String) -> Bool {
        let test = NSPredicate(format:"SELF MATCHES %@", pattern)
        return test.evaluate(with: value)
    }
}
