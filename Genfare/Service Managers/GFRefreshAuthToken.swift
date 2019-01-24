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
    
    class func refresh(completionHandler:@escaping (_ success:Bool?,_ error:Any?) -> Void) {
        guard let username = KeychainWrapper.standard.string(forKey: Constants.KeyChain.UserName),
        let password = KeychainWrapper.standard.string(forKey: Constants.KeyChain.Password) else {
            completionHandler(false,"User Credentials Not found in KeyChain")
            return
        }
        
        let endpoint = GFEndpoint.RefreshToken(email: username, password: password)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: URLEncoding.default, headers: endpoint.headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    let response = JSON as! NSDictionary
                    let accesstoken = response.object(forKey: "access_token")
                    KeychainWrapper.standard.set(accesstoken as! String, forKey: Constants.KeyChain.SecretKey)
                    completionHandler(true,"")
                    print("Token : \(accesstoken)")
                case .failure(let error):
                    completionHandler(false,"Request failed with error: \(error)")
                    print("Request failed with error: \(error)")
                }
        }
    }
}
