//
//  GFConfigService.swift
//  Genfare
//
//  Created by omniwyse on 28/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFConfigService{
    
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

    func fetchConfigurationValues(completionHandler:@escaping (_ success:Bool?,_ error:Any?) -> Void) {
        let endpoint = GFEndpoint.GetConfigApi()
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    //print(JSON)
                    if let json = JSON as? [String:Any] {
                        if let code = json["code"] as? String, code == "401" {
                            //TODO - Auth token expired, refresh token
                        }else{
                            self.saveConfiguredValues(data: json)
                        }
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
    
    func saveConfiguredValues(data:[String:Any]) {
        
        GFDataService.deleteAllRecords(entity: "Configure")
        
        let managedContext = GFDataService.context
        let configureContents = NSEntityDescription.entity(forEntityName: "Configure", in: managedContext)
        let configObj:Configure = NSManagedObject(entity: configureContents!, insertInto: managedContext) as! Configure

        configObj.agencyContactNumber = data["AgencyContactNumber"] as? String
        configObj.agencyId = data["AgencyId"] as? NSNumber
        configObj.barcodeActivationOffSetInMins = data["barcodeActivationOffsetInMins"] as? NSNumber
        configObj.key12 = data["key12"] as? String
        configObj.transitId = data["TransitId"] as? String
        configObj.endOfTransitDay = data["EndOfTransitDay"] as? NSNumber
        if let loyality = data["LoyaltyProgram"] as? [String:Any], let bonus = loyality["BONUS_RIDE"] as? [String:Any],let capped = loyality["CAPPED_RIDE"] as? [String:Any]{
                  if bonus.count > 1 {
                        configObj.bonusDelay = bonus["Delay"] as? NSNumber
                        configObj.bonusFarecode = bonus["FareCode"] as?  String
                        configObj.bonusThreshold = bonus["Threshold"] as? NSNumber
                        configObj.bonusTicketid  = bonus["TicketId"] as? NSNumber
                                      }
                 if capped.count > 1 {
                        configObj.cappedDelay = capped["Delay"] as? NSNumber
                        configObj.cappedFarecode = capped["FareCode"] as?  String
                        configObj.cappedThreshold = capped["Threshold"] as? NSNumber
                        configObj.cappedTicketId  = capped["TicketId"] as? NSNumber
            
        }
        }
        if let orderlimits = data["orderLimits"] as? [String:Any], let value = orderlimits["registeredUser"] as? [String:Any]{
                        configObj.configMax = value["max"] as? NSNumber
                        configObj.configMin = value["min"] as? NSNumber
            
        }
         GFDataService.saveContext()
    }
}
