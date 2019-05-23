//
//  PurchaseTicketListViewModel.swift
//  Genfare
//
//  Created by omniwyse on 02/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class PurchaseTicketListViewModel{
    let disposebag = DisposeBag()
    
      var productsListArrayModel = [[String:Any]]()
     var productsListArrayPayAsYouGoModel = [AnyObject]()
    var products:Array<Product> = []
    var quantityValue = 0
    var fare = 0.0
    var seletedArray = [[String:Any]]()
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    var payAsYouGoTextFieldtext = ""
    func showProducts() {
      products =  GFFetchProductsService.getProducts()
        isSuccess.value = true
    }
    
    func getProductcount() -> Int{
        products =  GFFetchProductsService.getProducts()
        return products.count
        }
    func formErrorString() -> String {
        return ""
    }
    func targetMethod(){
        if products.count > 0{
            var  filteredProdcutArray = returnStoredValueProducts()
            print(filteredProdcutArray)
            for i in filteredProdcutArray{
                var dict = [String:Any]()
                dict["productDescription"] = i.productDescription
                dict["offeringId"] = i.offeringId
                dict["ticketId"] = i.ticketId
                dict["price"] = i.price
                dict["ticketTypeDescription"] = i.ticketTypeDescription
                dict["ticket_count"] = quantityValue
                dict["total_ticket_fare"] = fare
                self.productsListArrayModel.append(dict)
              //  isSuccess.value = true
                
            }

            
        }
        
    }
    func payasyougo(){
        if products.count > 0 {
            productsListArrayPayAsYouGoModel.removeAll()
            var filteredProductArrayPayAsYouGo  = returnStoredValueWithActivation()
            print(filteredProductArrayPayAsYouGo)
            for i in filteredProductArrayPayAsYouGo{
                if(!(payAsYouGoTextFieldtext.isEmpty)){
                    //  if(self.PayAsYouGoTextField.text.length>0){
                    var dict: [AnyHashable : Any] = [:]
                    dict["productDescription"] = i.productDescription
                    dict["offeringId"] = i.offeringId
                    dict["ticketId"] = i.ticketId
                    dict["price"] = i.price
                    dict["ticketTypeDescription"] = i.ticketTypeDescription
                    dict["ticket_count"] = 0
                    dict["total_ticket_fare"] = payAsYouGoTextFieldtext
                    productsListArrayPayAsYouGoModel.append(dict as AnyObject)
                }
            }
            print(productsListArrayPayAsYouGoModel)
            
        }
        
    }
    func returnStoredValueWithActivation() -> [Product]{
        var arrStoredProds = [Product]()
        for prod in products{
            if let objProd = prod as? Product{
                if let ticetDesc = objProd.ticketTypeDescription, let active = objProd.isActivationOnly{
                    if ticetDesc == "Stored Value" && active == 0 {
                        arrStoredProds.append(objProd)
                    }
                }
            }
        }
        return arrStoredProds
    }
    
    func returnStoredValueProducts() -> [Product]{
        var arrStoredProds = [Product]()
        for prod in products{
            if let objProd = prod as? Product{
                if let ticetDesc = objProd.ticketTypeDescription{
                    if ticetDesc != "Stored Value"{
                        arrStoredProds.append(objProd)
                    }
                }
            }
        }
        return arrStoredProds
    }
    
    func getTotalAmountforvalidations() -> Int{
        var  totalAmount = 0
        seletedArray.removeAll()
        for j in 0..<productsListArrayModel.count {
            let count = productsListArrayModel[j]["ticket_count"] as? Int
            if !(count == 0) {
                
                seletedArray.append(productsListArrayModel[j] as! [String : Any])
                totalAmount = totalAmount + ((productsListArrayModel[j]["total_ticket_fare"] as? NSNumber)?.intValue)! ?? 0
            }
        }
        
        let payAsYouGoAmountValue =   UserDefaults.standard.integer(forKey: "payasyougoamount")
        totalAmount = totalAmount + payAsYouGoAmountValue
        return totalAmount
    }
    
    
}
