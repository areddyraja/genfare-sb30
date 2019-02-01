//
//  GFRefreshAuthToken.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFRefreshAuthToken {
    
    static func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        if let authorizationHeader = Request.authorizationHeader(user: Utilities.authUserID(),password: Utilities.authPassword()) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        return headers
    }
    
    static func parameters(username:String,password:String) -> [String:String] {
        let parameters = ["username":username,
                          "password":password]
        return parameters
    }

    static func refresh(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        guard let username = KeychainWrapper.standard.string(forKey: Constants.KeyChain.UserName),
        let password = KeychainWrapper.standard.string(forKey: Constants.KeyChain.Password) else {
            completionHandler(false,"User Credentials Not found in KeyChain")
            return
        }
        
        let endpoint = GFEndpoint.RefreshToken(email: username, password: password)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(username: username, password: password), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    let response = JSON as! NSDictionary
                    
                    if let accesstoken = response.object(forKey: "access_token") {
                        KeychainWrapper.standard.set(accesstoken as! String, forKey: Constants.KeyChain.SecretKey)
                        completionHandler(true,"")
                        print("Token : \(accesstoken)")
                    }else{
                        completionHandler(false,"Unable to fetch access token")
                    }
                case .failure(let error):
                    completionHandler(false,"Request failed with error: \(error)")
                    print("Request failed with error: \(error)")
                }
        }
    }
}
