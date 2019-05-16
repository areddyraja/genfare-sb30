//
//  GFGetWalletStatusService.swift
//  Genfare
//
//  Created by omniwyse on 15/05/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFGetWalletStatusService {
    
    var walletID:NSNumber?
    
    init(walletID:NSNumber) {
        self.walletID = walletID
    }
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        headers["Authorization"] = String(format: "bearer %@", token)
        
        return headers
    }
    
    func parameters() -> [String:String] {
        return [:]
    }
    
    func fetchStatus(completionHandler:@escaping (_ result:Any?,_ error:Any?) -> Void) {
        let endpoint = GFEndpoint.GetWalletStatus(walletId: walletID!)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                  if let json = JSON as? [String:Any], let walletData = json["result"] as? [String:Any] {
                    GFWalletsService.saveWalletData(data: walletData)
                    completionHandler(true,nil)
                }else{
                    completionHandler(false,"Unknown error")
                }

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(nil,error)
                }
        }
    }
}
