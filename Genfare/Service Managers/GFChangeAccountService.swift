//
//  GFChangeAccountService.swift
//  Genfare
//
//  Created by omniwyse on 08/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFChangeAccountService{
    
    var email:String = ""
    var password:String = ""
    
    
    init(email:String,password:String){
        self.email = email
        self.password = password
    }
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        headers["Authorization"] = String(format: "bearer %@", token)
      //  headers["Authorization"] = String(format: "bearer %@", Utilities.accessToken())
        
        return headers
    }
    
    func parameters() -> [String:String] {
         let account:Account = GFDataService.currentAccount()!
        let firstname = account.firstName as! String
        let lastname  = account.lastName as! String
        let parameters = ["firstName":firstname,
                          "lastName" :lastname,
                          "id":email,
                          "password":password]
        
        return parameters
    
    }
    
    func changeUserParameter(completionHandler:@escaping (_ result:Bool,_ error:Any?) -> Void){
        let endpoint = GFEndpoint.ChangeUser(email: email, password: password)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: JSONEncoding.default, headers: headers())
            .responseJSON { [weak self] response in
                switch response.result {
                case .success(let JSON):
                    //print(JSON)
                    let dict = JSON as? [String:Any]
                    if let success:Bool = dict!["success"] as! Bool{
                    if(!success){
                        completionHandler(false,dict?["message"])
                    }
                    }else{
                        KeychainWrapper.standard.set(self!.email, forKey:Constants.KeyChain.UserName)
                        KeychainWrapper.standard.set(self!.password, forKey: Constants.KeyChain.Password)
                       
                        completionHandler(true,dict?["message"])
                    }
                
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error.localizedDescription)
                }
        }
}
}
