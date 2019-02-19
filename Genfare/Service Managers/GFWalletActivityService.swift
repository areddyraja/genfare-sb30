//
//  GFWalletActivityService.swift
//  Genfare
//
//  Created by vishnu on 01/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFWalletActivityService {
    
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
    
    func fetchHistory(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.FetchWalletActivity(walletId: walletID!)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    if let json = JSON as? [String:Any] {
                        if let items = json["result"] as? Array<Any> {
                            self.saveHistory(data: items)
                        }
                    }
                    completionHandler(true,nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error.localizedDescription)
                }
        }
    }
    
    func saveHistory(data:Array<Any>) {
        GFDataService.deleteAllRecords(entity: "WalletActivity")
        
        let managedContext = GFDataService.context
        let history = NSEntityDescription.entity(forEntityName: "WalletActivity", in: managedContext)
        
        for prod in data {
            let userObj:WalletActivity = NSManagedObject(entity: history!, insertInto: managedContext) as! WalletActivity
            
            if let item = prod as? [String:Any] {
                userObj.activityId = item["activityId"] as? NSNumber
                userObj.activityTypeId = item["activityTypeId"] as? NSNumber
                userObj.amountCharged = item["amountCharged"] as? NSNumber
                userObj.amountRemaining = item["amountRemaining"] as? NSNumber
                userObj.date = item["date"] as? NSNumber
                userObj.event = item["event"] as? String
                userObj.ticketId = item["ticketId"] as? NSNumber
            }
        }
        
        GFDataService.saveContext()
        print(GFWalletActivityService.getHistory())
    }
    
    static func getHistory() -> Array<WalletActivity> {
        let records:Array<WalletActivity> = GFDataService.fetchRecords(entity: "WalletActivity") as! Array<WalletActivity>
        
        if records.count > 0 {
            return records
        }
        
        return []
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
