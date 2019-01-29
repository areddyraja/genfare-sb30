//
//  GFConfigService.swift
//  Genfare
//
//  Created by omniwyse on 28/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
class GFConfigService{
    
    init(){}
    
    func fetchConfigurationValues(completionHandler:@escaping (_ success:Bool?,_ error:Any?) -> Void) {
        let endpoint = GFEndpoint.GetConfigApi()
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: URLEncoding.default, headers: endpoint.headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error)
                }
        }
    }
    
}
