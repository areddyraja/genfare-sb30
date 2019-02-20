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
    
    init(walletID:NSNumber,ticketid:NSNumber) {
        self.walletID = walletID
        self.ticketID = ticketid
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
    
    func execute(completionHandler:@escaping (_ success:Bool,_ error:Any?) -> Void) {
        
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
    
    static func updateActivityFor(product:Product,wallet:WalletContents,activity:String) {
        switch activity {
        case "activation":
            let managedContext = GFDataService.context
            let event = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)
            let userObj:Event = NSManagedObject(entity: event!, insertInto: managedContext) as! Event
            let cdate:Double = Date().timeIntervalSince1970
            
            userObj.clickedTime = cdate as NSNumber
            userObj.fare = wallet.fare
            userObj.identifier = wallet.identifier
            userObj.ticketid = "\(product.ticketId!)"
            userObj.type = "activation"
            userObj.ticketActivationExpiryDate = "\(cdate + (product.barcodeTimer as! Double))"
            
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
                activeTicket.ticketActivationExpiryDate = (cdate + (barcodeTime as! Double)) as NSNumber
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
