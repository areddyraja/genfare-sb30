//
//  GFWalletEventService.swift
//  Genfare
//
//  Created by vishnu on 19/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class GFWalletEventService {
    
    var walletID:NSNumber!
    var ticketID:NSNumber!
    var clickedTime:Any!
    var event:Event!
    
    
    init(walletID:NSNumber,ticketid:NSNumber,clickedTime:Any!,event:Event) {
        self.walletID = walletID
        self.ticketID = ticketid
         self.clickedTime = clickedTime
        self.event = event
    }
    
    func headers() -> HTTPHeaders {
        var headers = GFEndpoint.commonHeaders
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        headers["Authorization"] = String(format: "bearer %@", token)
        
        return headers
    }
    
    func parameters() -> [String:Any] {
        let cdate =  Date().toMillis()
        let parameters = ["chargeDate":cdate!]
        return parameters
    }
    
    func execute(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        var arrProductsList = [[String:Any]]()
        var storedDict = [String:Any]()
        let cdate =  Date().toMillis()
        if(event.type == Constants.Ticket.PeriodPass){
            storedDict["chargeDate"] = event.clickedTime
        }else{
             storedDict["chargeDate"] = event.clickedTime
            storedDict["ticketIdentifier"] = self.ticketID
            storedDict["amountCharged"] = event.fare
            if Utilities.isLoginCardBased(){
                storedDict["amountRemaining"] = Utilities.walletContentsBalance()
            }else{
                storedDict["amountRemaining"] = Utilities.accountBalance()
            }
            
        }
       
     //   storedDict["chargedamount"] = event.ch
        
            
    
        arrProductsList.append(storedDict)
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        let url1 = "/services/data-api/mobile/wallets/\(self.walletID!)/contents/\(self.ticketID!)/charge?tenant=\(Utilities.tenantId())"
        let url =  Utilities.apiHost()+url1
        var request = URLRequest(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Utilities.appCurrentVersion(), forHTTPHeaderField: "app_version")
        request.setValue("iOS", forHTTPHeaderField: "app_os")
        request.setValue(Utilities.deviceId(), forHTTPHeaderField: "DeviceId")
        request.setValue(String(format: "bearer %@", token), forHTTPHeaderField: "Authorization")
        let ordervalue:[[String:Any]]
        ordervalue = arrProductsList
        let values = ordervalue
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        
        Alamofire.request(request)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                        completionHandler(false,error.localizedDescription)
                    }
                case .success(let JSON):
                    if let json = JSON as? [String:Any] {
                    }
                    completionHandler(true,nil)
                }
        }
    }
    
    func execute1(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.WalletEvent(walletId: walletID, tickedId: ticketID)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: parameters(), encoding: URLEncoding.default, headers: headers())
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    if let json = JSON as? [String:Any] {
                        print(json)
                    }
                    completionHandler(true,nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(false,error.localizedDescription)
                }
        }
    }
    
    static func uploadEventTable() {
        
    }
    
    static func updateActivityFor(product:Product,wallet:WalletContents,activity:String) {
        switch activity {
        case "activation":
            let managedContext = GFDataService.context
            let event = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)
            let userObj:Event = NSManagedObject(entity: event!, insertInto: managedContext) as! Event
            let cdate:Double = Date().timeIntervalSince1970
            
            userObj.clickedTime = cdate * 1000 as NSNumber
            // userObj.fare = wallet.fare
            userObj.identifier = wallet.identifier
            userObj.type = wallet.type
            userObj.ticketActivationExpiryDate = "\(cdate + (product.barcodeTimer as! Double))"
            
            let loyaltyData = GFLoyaltyData(product: product)
            let loyalty = GFLoyaltyService(dataProvider: loyaltyData)
            
            if loyalty.isProductEligibleForCappedRide() {
                userObj.ticketid = "\(loyalty.dataProvider.cappedTicketId)"
                userObj.fare = 0
            }else if loyalty.isProductEligibleForBonusRide() {
                userObj.ticketid = "\(loyalty.dataProvider.bonusTicketId)"
                userObj.fare = 0
            }else{
                userObj.ticketid = "\(product.ticketId!)"
                userObj.fare = NumberFormatter().number(from: product.price!)!
            }
            
            if Utilities.isLoginCardBased(){
                let originalBalance = Utilities.walletContentsBalance()
                let productFare = NumberFormatter().number(from: product.price!)!
                let remainingBal:Float = originalBalance.floatValue - productFare.floatValue
                userObj.amountRemaining = NSNumber.init(value: remainingBal)
            }else{
                userObj.amountRemaining = Utilities.accountBalance()
            }
            
            
            GFDataService.saveContext()
            print(userObj)
        default:
            //
            print(wallet)
        }
    }
    
    static func activateTicket(ticket:WalletContents) {
        let barcodeTime = GFFetchProductsService.barcodeTimerFor(pid: ticket.ticketIdentifier!)
        let cdate:Double = Date().timeIntervalSince1970

        let managedContext = GFDataService.context
        do {
            let fetchRequest:NSFetchRequest = WalletContents.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", ticket.identifier!)
            let fetchResults = try managedContext.fetch(fetchRequest) as! Array<WalletContents>
            if fetchResults.count > 0 {
                let activeTicket:WalletContents = fetchResults.first!
                activeTicket.status = "active"
                activeTicket.ticketActivationExpiryDate = Int64(cdate + (barcodeTime as! Double)) as NSNumber
                activeTicket.expirationDate = GFWalletContentsService.calculateExpDate(item: ticket)
                activeTicket.generationDate = Int64(NSDate().timeIntervalSince1970 * 1000) as NSNumber
                activeTicket.activationDate = Int64(NSDate().timeIntervalSince1970 * 1000) as NSNumber
                
                print(activeTicket)
                GFDataService.saveContext()
            }
        }catch{
            print("Can't fetch records")
        }
    }
}
extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
