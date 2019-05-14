//
//  GFLoginService.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFLoginService {
    
    var username:String = ""
    var password:String = ""
    
    var delegate:LoginServiceDelegate?
    
    init(username:String,password:String){
        self.username = username
        self.password = password
    }
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        headers["Authorization"] = String(format: "bearer %@", Utilities.accessToken())
        
        return headers
    }

    func parameters() -> [String:String] {
        let parameters = ["emailaddress":username,
                      "password":password]
        return parameters
    }

    func loginUser(completionHandler:@escaping (_ result:Bool,_ error:Any?) -> Void){
        let endpoint = GFEndpoint.LoginUser(email: username, password: password)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: JSONEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    //print(JSON)
                    if let dict = JSON as? [String:Any]{
                        if let success = dict["success"] as? Bool{
                            if(success){
                                KeychainWrapper.standard.set(self.username, forKey:Constants.KeyChain.UserName)
                                KeychainWrapper.standard.set(self.password, forKey: Constants.KeyChain.Password)
                                self.saveData(data: dict["result"] as! [String : Any])
                                completionHandler(true,dict["message"])
                            }else{
                                completionHandler(false,dict["message"])
                            }
                        }else{
                            completionHandler(false,dict["message"])
                        }
                        
                    }
                    //testpp@test.comtself.refreshToken(username: username, password: password)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error.localizedDescription)
                }
        }
    }
    
    func saveData(data:[String:Any]) {
        //Delete existing records if any before saving Account details
        GFDataService.deleteAllRecords(entity: "Account")
        
        let managedContext = GFDataService.context
        let account = NSEntityDescription.entity(forEntityName: "Account", in: managedContext)
        let userObj:Account = NSManagedObject(entity: account!, insertInto: managedContext) as! Account
        
        userObj.accountId = data["accountid"] as? String
        userObj.created = data["created"] as? String
        userObj.emailaddress = data["emailaddress"] as? String
        if let farecodearr:Array<String> = data["farecode"] as! Array<String>, farecodearr.count > 0 {
            userObj.farecode = farecodearr.first
        }
        userObj.firstName = data["firstname"] as? String
        userObj.id = data["id"] as? NSNumber
        userObj.lastlogin = data["lastlogin"] as? String
        userObj.lastName = data["lastname"] as? String
        userObj.mobilenumber = data["mobilenumber"] as? String
        userObj.needs_additional_auth = data["needs_additional_auth"] as? NSNumber
        userObj.profileType = data["profiletype"] as? String
        userObj.status = data["status"] as? String
        
        GFDataService.saveContext()
    }
    
}

protocol LoginServiceDelegate {
    func didFinishLoginSuccessfully(_ sender:Any)
    func didLoginNeedSMSAuth(_ sender:Any)
    func didLoginNeedWallet(_ sender:Any)
    func didFailLoginWithError(_ error:Any)
}

