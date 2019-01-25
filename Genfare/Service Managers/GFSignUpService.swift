//
//  GFSignUpService.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFSignUpService {
    
    var useremail:String = ""
    var password:String = ""
    var firstName:String = ""
    var lastName:String = ""
    
    var delegate:SignUpServiceDelegate?
    
    init(email:String,password:String,firstname:String,lastname:String) {
        self.useremail = email
        self.password = password
        self.firstName = firstname
        self.lastName = lastname
    }
    
    func registerUser(){
        let endpoint = GFEndpoint.RegisterUser(email: useremail, password: password, firstname: firstName, lastname: lastName)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: JSONEncoding.default, headers: endpoint.headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                    let dict = JSON as? [String:Any]
                    let success:Bool = dict!["success"] as! Bool
                    if(!success){
                        self.delegate?.didFailRegistration(dict?["message"] ?? "Registration failed.")
                    }else{
                        KeychainWrapper.standard.set(self.useremail, forKey:Constants.KeyChain.UserName)
                        KeychainWrapper.standard.set(self.password, forKey: Constants.KeyChain.Password)
                        self.delegate?.didRegisterSuccessfully()
                    }
                    
                case .failure(let error):
                    self.delegate?.didFailRegistration(error.localizedDescription)
                    print("Request failed with error: \(error)")
                }
        }
    }
}

protocol SignUpServiceDelegate {
    func didRegisterSuccessfully()
    func didFailRegistration(_ error:Any)
}
