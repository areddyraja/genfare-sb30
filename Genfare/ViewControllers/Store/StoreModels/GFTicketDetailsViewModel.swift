//
//  GFTicketDetailsViewModel.swift
//  Genfare
//
//  Created by omniwyse on 08/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class GFTicketDetailsViewModel{
    let disposebag = DisposeBag()
    
   
    var seletedProductsModel = [[String:Any]]()
    var arrNotStoredProds = [[String:Any]]()
    var arrStoredProds  = [[String:Any]]()
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
 
    func getArrayOfProducts() -> [[String:Any]]{
        var arrProductsList = [[String:Any]]()
        for (index,_) in self.arrStoredProds.enumerated(){
            let requiredObj = self.arrStoredProds[index]
            var storedDict = [String:Any]()
            storedDict["offeringId"] = requiredObj["offeringId"]
            storedDict["value"] = requiredObj["total_ticket_fare"]
            arrProductsList.append(storedDict)
        }
        for (index,_) in self.arrNotStoredProds.enumerated(){
            let requiredObj = self.arrNotStoredProds[index]
            var notStoredDict = [String:Any]()
            notStoredDict["offeringId"] = requiredObj["offeringId"]
            notStoredDict["quantity"] = requiredObj["ticket_count"]
            arrProductsList.append(notStoredDict)
            
        }
        return arrProductsList
    }
    
    
    func getSelectedProducts(){
        self.arrStoredProds.removeAll()
        self.arrNotStoredProds.removeAll()
        for prod in seletedProductsModel{
            if let ticketDesc = prod["ticketTypeDescription"] as? String{
                if ticketDesc != "Stored Value"{
                    arrNotStoredProds.append(prod)
                }else{
                    arrStoredProds.append(prod)
                }
            }
        }
    }
}
