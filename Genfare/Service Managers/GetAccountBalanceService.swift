//
//  GetAccountBalanceService.swift
//  Genfare
//
//  Created by omniwyse on 28/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFAccountBalanceService{
    
    init(){}
    
    private static func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        headers["Authorization"] = String(format: "bearer %@", token)
        
        return headers
    }
    
    private static func parameters() -> [String:String] {
        return [:]
    }

    static func fetchAccountBalance(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        let endpoint = GFEndpoint.GetAccountBalance()
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    //print(JSON)
                    if let json = JSON as? [String:Any], let balance = json["balance"] as? NSNumber {
                        Utilities.saveAccountBalance(bal: balance)
                    }
                    completionHandler(true,nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error)
                }
        }
    }
}
