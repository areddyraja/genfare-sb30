//
//  GFWalletContentsService.swift
//  Genfare
//
//  Created by vishnu on 29/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFWalletContentsService {
    
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
    
    func getWalletContents(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.WalletContents(walledId: walletID!)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                    if let json = JSON as? Array<Any> {
                        self.saveWalletContents(data: json)
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
    
    func saveWalletContents(data:Array<Any>) {
        let managedContext = GFDataService.context
        let walletContents = NSEntityDescription.entity(forEntityName: "WalletContents", in: managedContext)
        
        for item in data {
            var userObj:WalletContents
            
            if let wItem = item as? [String:Any] {
                do {
                    let fetchRequest:NSFetchRequest = WalletContents.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "ticketIdentifier == %@", (wItem["ticketIdentifier"] as? String)!)
                    let fetchResults = try managedContext.fetch(fetchRequest) as! Array<WalletContents>
                    if fetchResults.count <= 0 {
                        userObj = NSManagedObject(entity: walletContents!, insertInto: managedContext) as! WalletContents
                    }else{
                        userObj = fetchResults.first!
                    }
                    userObj.activationCount = wItem["activationCount"] as? NSNumber
                    userObj.expirationDate = wItem["expirationDate"] as? String
                    userObj.agencyId = wItem["agencyId"] as? NSNumber
                    userObj.balance = wItem["balance"] as? String
                    userObj.descriptation = wItem["description"] as? String
                    userObj.designator = wItem["designator"] as? NSNumber
                    userObj.fare = wItem["fare"] as? NSNumber
                    userObj.group = wItem["group"] as? String
                    userObj.identifier = wItem["identifier"] as? String
                    userObj.purchasedDate = wItem["purchasedDate"] as? NSNumber
                    userObj.slot = wItem["slot"] as? NSNumber
                    userObj.status = wItem["status"] as? String
                    userObj.ticketIdentifier = wItem["ticketIdentifier"] as? String
                    userObj.type = wItem["type"] as? String
                    userObj.valueOriginal = wItem["valueOriginal"] as? NSNumber
                    userObj.valueRemaining = wItem["valueRemaining"] as? NSNumber
                    userObj.ticketEffectiveDate = wItem["ticketEffectiveDate"] as? NSNumber
                    userObj.ticketExpiryDate = wItem["ticketExpiryDate"] as? NSNumber
                    if let attbs = wItem["attributes"] as? [String:Any], let attb = attbs["Attribute"] as? Array<Any> {
                        if attb.count > 1 {
                            if let subItem = attb[1] as? [String:Any] {
                                userObj.member = subItem["value"] as? String
                            }
                        }
                        if attb.count > 0 {
                            if let subItem = attb[0] as? [String:Any] {
                                userObj.ticketGroup = subItem["value"] as? String
                            }
                        }
                    }
                    print(userObj)
                }catch{
                    print("saving failed ")
                }
            }
        }
        GFDataService.saveContext()
    }
    
    static func getContents() -> Array<WalletContents> {
        let records:Array<WalletContents> = GFDataService.fetchRecords(entity: "WalletContents") as! Array<WalletContents>
        
        if records.count > 0 {
            return records
        }
        
        return []
    }

    static func updateExpirationDate(ticketID:String) {
        let managedContext = GFDataService.context
        do {
            let fetchRequest:NSFetchRequest = WalletContents.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "ticketIdentifier == %@", ticketID)
            let fetchResults = try managedContext.fetch(fetchRequest) as! Array<WalletContents>
            if fetchResults.count > 0 {
                let userObj = fetchResults.first!
                userObj.expirationDate = calculateExpDate(item: fetchResults.first!)
                userObj.status = "active"
                GFDataService.saveContext()
            }
        }catch{
            print("Update failed")
        }
    }
    
    private static func calculateExpDate(item:WalletContents) -> String {
        if item.type == Constants.Ticket.PeriodPass {
            let currentSecs = Date().timeIntervalSince1970
            let remainingTime = 24*60*60*(item.valueRemaining as! Double)
            let actualTime = remainingTime+(currentSecs as Double)
            let df = DateFormatter()
            df.dateFormat = Constants.Ticket.ExpDateFormat
            let edate = Date(timeIntervalSince1970: TimeInterval(actualTime))
            return df.string(from: edate)
        }
        return ""
    }
}
