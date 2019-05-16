//
//  GFCheckWalletService.swift
//  Genfare
//
//  Created by vishnu on 25/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFCheckWalletService {
    
    init(){}
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        headers["Authorization"] = String(format: "bearer %@", token)
        
        return headers
    }
    
    func parameters() -> [String:String] {
        return [:]
    }

    func fetchWallets(completionHandler:@escaping (_ result:Any?,_ error:Any?) -> Void) {
        let endpoint = GFEndpoint.CheckWalletService()
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    //print(JSON)
                    let records:[String:Any] = JSON as! [String:Any]
                    
                    if let wallets:Array<Any> = records["result"] as! Array<Any> {
                        print("Wallet length - \(wallets.count)")
                        if wallets.count < 0 {
                            GFDataService.deleteAllRecords(entity: "Wallet")
                        }
                        completionHandler(wallets,nil)
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(nil,error)
                }
        }
    }
}
