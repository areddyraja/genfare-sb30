//
//  GFFirstAuthToken.swift
//  Genfare
//
//  Created by vishnu on 30/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFFirstAuthToken {
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        if let authorizationHeader = Request.authorizationHeader(user: Utilities.authUserID(),password: Utilities.authPassword()) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        return headers
    }

    func getAuthToken(completionHandler:@escaping (_ result:Bool,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.GetAuthToken(clientId: Utilities.authUserID())
        
        Alamofire.request(endpoint.url,headers:headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    let response = JSON as! [String: Any]
                    if let accesstoken = response["access_token"] {
                        Utilities.saveAccessToken(token: accesstoken as! String)
                    }
                    completionHandler(true,nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error.localizedDescription)
                }
        }
    }

}
