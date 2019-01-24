//
//  GFLoginService.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFLoginService {
    
    var username:String?
    var password:String?
    
    var delegate:LoginServiceDelegate?
    
    init(username:String,password:String){
        self.username = username
        self.password = password
    }
    
    func loginUser(){
        let endpoint = GFEndpoint.LoginUser(email: username!, password: password!)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: JSONEncoding.default, headers: endpoint.headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                    let dict = JSON as? [String:Any]
                    let success:Bool = dict!["success"] as! Bool
                    if(!success){
                        self.delegate?.didFailLoginWithError(dict?["message"])
                    }else{
                        KeychainWrapper.standard.set(self.username!, forKey:Constants.KeyChain.UserName)
                        KeychainWrapper.standard.set(self.password!, forKey: Constants.KeyChain.Password)
                        GFRefreshAuthToken.refresh(completionHandler: { success, error in
                            if(success!){
                                self.delegate?.didFinishLoginSuccessfully(self)
                            }else{
                                self.delegate?.didFailLoginWithError(error)
                            }
                        })
                    }
                    //testpp@test.comtself.refreshToken(username: username, password: password)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.delegate?.didFailLoginWithError(error)
                }
        }
    }
}

protocol LoginServiceDelegate {
    func didFinishLoginSuccessfully(_ sender:Any)
    func didLoginNeedSMSAuth(_ sender:Any)
    func didLoginNeedWallet(_ sender:Any)
    func didFailLoginWithError(_ error:Any)
}
