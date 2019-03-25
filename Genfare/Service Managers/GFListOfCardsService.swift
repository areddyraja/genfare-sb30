//
//  GFListOfCardsService.swift
//  Genfare
//
//  Created by omniwyse on 15/03/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFListOfCardsService {
    
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        headers["Authorization"] = String(format: "bearer %@", token)
        
        return headers
    }
    
    func parameters() -> [String:String] {
        return [:]
    }
    
    func GetlistOfCards(completionHandler:@escaping (_ result:Any?,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.ListOfCards()
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    if let json = JSON as? [String:Any] {
                        if let items = json["result"] as? Array<Any> {
                            completionHandler(items,nil)
                        }
                    }
                    case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(nil,error)
                }
        }
    }
   
}
