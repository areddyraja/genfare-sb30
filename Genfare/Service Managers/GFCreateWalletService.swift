//
//  GFCreateWalletService.swift
//  Genfare
//
//  Created by vishnu on 30/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFCreateWalletService {
    
    var nickname:String = ""
    
    init(nickname:String) {
        self.nickname = nickname
    }
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        headers["Authorization"] = String(format: "bearer %@", token)
        
        return headers
    }
    
    func parameters() -> [String:String] {
        let account:Account = GFAccountManager.currentAccount()!
        let parameters = ["nickname":nickname,
                          "personId":account.accountId!,
                          "deviceUUID":Utilities.deviceId()]
        return parameters
    }

    func createWallet(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        let endpoint = GFEndpoint.CreateWallet(wallet: nickname)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: JSONEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    //print(JSON)
                    if let json = JSON as? [String:Any], let walletData = json["result"] as? [String:Any] {
                        GFWalletsService.saveWalletData(data: walletData)
                        completionHandler(true,nil)
                    }else{
                        completionHandler(false,"Unknown error")
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error.localizedDescription)
                }
        }
    }
}
