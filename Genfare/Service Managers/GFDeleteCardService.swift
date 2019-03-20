//
//  GFDeleteCardService.swift
//  Genfare
//
//  Created by omniwyse on 19/03/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFDeleteCardService{
    

var cardNumber:Int?

init(cardNumber:Int) {
    self.cardNumber = cardNumber
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
    
    func deleteCard(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.DeleteCard(cardNumber: cardNumber!)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: JSONEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                    if let json = JSON as? Array<Any> {
                        completionHandler(true,nil)
                    }else{
                        completionHandler(false,"Error")
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error)
                }
        }
    }
}
