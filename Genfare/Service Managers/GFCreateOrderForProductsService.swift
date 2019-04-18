//
//  GFCreateOrderForProductsService.swift
//  Genfare
//
//  Created by omniwyse on 06/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

class GFCreateOrderForProductsService{
    var walletID:NSNumber?
    var orderArray:[[String:Any]]
    init(order:[[String:Any]], walletID: NSNumber?) {
        self.walletID = walletID
        self.orderArray = order
    }
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        headers["Authorization"] = String(format: "bearer %@", token)
        
        return headers
    }
    
    func parameters() -> Array<Any> {
        return orderArray
    }
    
    func createOrderService(completionHandler:@escaping (_ success:Bool?,_ error:Any?) -> Void) {
      let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!

      let  url1 = "/services/data-api/mobile/wallets/\(walletID!)/order?tenant=\(Utilities.tenantId())"
         let url =  Utilities.apiHost()+url1
        var request = URLRequest(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Utilities.appCurrentVersion(), forHTTPHeaderField: "app_version")
        request.setValue("iOS", forHTTPHeaderField: "app_os")
        request.setValue(Utilities.deviceId(), forHTTPHeaderField: "DeviceId")
        request.setValue(String(format: "bearer %@", token), forHTTPHeaderField: "Authorization")
        let values = orderArray
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        
        Alamofire.request(request)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                    completionHandler(false,"Request failed with error: \(error)")
                    }
                case .success(let JSON):
                    if let json = JSON as? [String:Any] {
                        if let orderNumber = json["result"]{
                   UserDefaults.standard.set(orderNumber, forKey: "orderNumber")
                            completionHandler(true,nil)
                            
                        }
                    }
                }
        }
}
}
