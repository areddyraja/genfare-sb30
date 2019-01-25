//
//  GFLoginService.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import AERecord
import CoreData

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
                        self.saveData(data: dict!["result"] as! [String : Any])
                        GFRefreshAuthToken.refresh(completionHandler: { success, error in
                            if(success!){
                                self.delegate?.didFinishLoginSuccessfully(self)
                                self.checkForWallets()
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
    
    func checkForWallets() {
        let walletService = GFWalletsService()
        walletService.fetchWallets { (success, error) in
            if success! {
                print("Wallet retreived successfully")
                //Check for wallets availability and present with respectiv e screen
                //if wallet is there present account screen
                //else create wallet screen
            }else{
                print(error)
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
        //userObj.farecode = data["farecode"] as! String
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
