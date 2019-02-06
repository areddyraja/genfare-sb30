//
//  GFFetchProductsService.swift
//  Genfare
//
//  Created by vishnu on 31/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFFetchProductsService: GFBaseService {
    
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
    
    func getProducts(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.FetchProducts(walletId: walletID!)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                    if let json = JSON as? Array<Any> {
                        self.saveProducts(data: json)
                        completionHandler(true,nil)
                    }else{
                        if let json = JSON as? [String:Any] {
                            if let code = json["code"] as? String, code == "401" {
                                GFRefreshAuthToken.refresh(completionHandler: { [weak self] (success, error) in
                                    if success, (self != nil) {
                                        self!.getProducts(completionHandler: { (success, error) in
                                            completionHandler(success,error)
                                        })
                                    }else{
                                        completionHandler(false,error)
                                    }
                                })
                            }else{
                                completionHandler(false,"Unknown Error Occoured")
                            }
                        }else{
                            completionHandler(false,"Unknown Error Occoured")
                        }
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error.localizedDescription)
                }
        }
    }
    
    func saveProducts(data:Array<Any>) {
        GFDataService.deleteAllRecords(entity: "Product")

        let managedContext = GFDataService.context
        let product = NSEntityDescription.entity(forEntityName: "Product", in: managedContext)
        
        for prod in data {
            let userObj:Product = NSManagedObject(entity: product!, insertInto: managedContext) as! Product

            if let prodItem = prod as? [String:Any] {
                userObj.barcodeTimer = prodItem["barcodeTimer"] as? NSNumber
                userObj.designator = prodItem["designator"] as? String
                userObj.displayOrder = prodItem["displayOrder"] as? NSNumber
                userObj.fareCode = prodItem["fareCode"] as? String
                userObj.isActivationOnly = prodItem["isActivationOnly"] as? NSNumber
                userObj.isBonusRideEnabled = prodItem["isBonusRideEnabled"] as? NSNumber
                userObj.isCappedRideEnabled = prodItem["isCappedRideEnabled"] as? NSNumber
                userObj.offeringId = prodItem["offeringId"] as? NSNumber
                userObj.price = String(describing: prodItem["price"]!) as? String
                userObj.productDescription = prodItem["productDescription"] as? String
                userObj.ticketId = prodItem["ticketId"] as? NSNumber
                userObj.ticketSubTypeId = prodItem["ticketSubTypeId"] as? String
                userObj.ticketTypeDescription = prodItem["ticketTypeDescription"] as? String
                userObj.ticketTypeId = prodItem["ticketTypeId"] as? String
            }
        }
        
        GFDataService.saveContext()
        print(GFFetchProductsService.getProducts())
    }
    
    static func getProducts() -> Array<Product> {
        let records:Array<Product> = GFDataService.fetchRecords(entity: "Product") as! Array<Product>
        
        if records.count > 0 {
            return records
        }
        
        return []
    }
}
