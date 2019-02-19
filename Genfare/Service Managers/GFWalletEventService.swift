//
//  GFWalletEventService.swift
//  Genfare
//
//  Created by vishnu on 19/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFWalletEventService {
    
    var walletID:NSNumber!
    var ticketID:NSNumber!
    
    init(walletID:NSNumber,ticketid:NSNumber) {
        self.walletID = walletID
        self.ticketID = ticketid
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
    
    func execute(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.WalletEvent(walletId: walletID, tickedId: ticketID)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    if let json = JSON as? [String:Any] {
                        print(json)
                    }
                    completionHandler(true,nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error.localizedDescription)
                }
        }
    }
    
    static func updateActivityFor(product:Product,wallet:WalletContents,activity:String) {
        switch activity {
        case "activation":
            //
            print(product)
        default:
            //
            print(wallet)
        }
    }
}
