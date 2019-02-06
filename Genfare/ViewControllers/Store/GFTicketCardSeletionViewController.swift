//
//  GFTicketCardSeletionViewController.swift
//  Genfare
//
//  Created by omniwyse on 05/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFTicketCardSeletionViewController: UIViewController {
    
    var productsCartArray = [[String:Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        OrderProducts()
        // Do any additional setup after loading the view.
        if self.productsCartArray.count > 0{
        }
    }
    
    func OrderProducts() {
        let orderedService = GFCreateOrderForProductsService(order:productsCartArray, walletID: GFWalletsService.walletID!)
        orderedService.createOrderService { (success,error) in
            if success! {
                print("ordered")
            }
            else{
                print("error")
            }
            
        }
    }

    @IBAction func paymentButtonPressed(_ sender: Any) {
        let navController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "GFPurchaseWebViewController") as? GFPurchaseWebViewController
      let  walletID =  GFWalletsService.walletID!
        var orderNumber =   UserDefaults.standard.integer(forKey: "orderNumber")
        let  url1 = "/services/data-api/mobile/payment/page?tenant=\(Utilities.tenantId())&orderId=\(orderNumber)&walletId=\(walletID)&saveForFuture=true"
        let url =  Utilities.apiHost()+url1
        navController?.weburl = url
       navigationController?.pushViewController(navController!, animated: true)
        
    }
}
