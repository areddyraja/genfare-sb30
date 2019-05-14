//
//  GFEncryptionKeys.swift
//  Genfare
//
//  Created by omniwyse on 28/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFEncryptionKeysService{
    
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

    func fetchEncryptionKeys(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        let endpoint = GFEndpoint.GetEncryptionKeys()
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    //print(JSON)
                    if let json = JSON as? [String:Any], let values = json["result"] as? [String:Any] {
                        self.saveData(data: values)
                    }
                    completionHandler(true,nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error)
                }
        }
    }
    
    func saveData(data:[String:Any]) {
        //Delete existing records if any before saving Account details
        GFDataService.deleteAllRecords(entity: "EncryptionKey")
        
        let managedContext = GFDataService.context
        let keys = NSEntityDescription.entity(forEntityName: "EncryptionKey", in: managedContext)
        let userObj:EncryptionKey = NSManagedObject(entity: keys!, insertInto: managedContext) as! EncryptionKey
        
        userObj.algorithm = data["algorithm"] as? String
        userObj.initializationVector = data["initializationVector"] as? String
        userObj.keyId = data["keyId"] as? String
        userObj.secretKey = data["secretKey"] as? String

        GFDataService.saveContext()
    }

    static func getEncryptionKey() -> EncryptionKey? {
        let records:Array<EncryptionKey> = GFDataService.fetchRecords(entity: "EncryptionKey") as! Array<EncryptionKey>
        
        if records.count > 0 {
            return records.first
        }
        
        return nil

    }

}
