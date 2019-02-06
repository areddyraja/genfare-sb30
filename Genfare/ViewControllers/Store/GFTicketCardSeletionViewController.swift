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

        // Do any additional setup after loading the view.
        if self.productsCartArray.count > 0{
        }
    }

    
//    func fetchConfigurationValues(completionHandler:@escaping (_ success:Bool?,_ error:Any?) -> Void) {
//        let endpoint = GFEndpoint.GetProductForWallet()
//
//        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: URLEncoding.default, headers: endpoint.headers)
//            .responseJSON { response in
//                switch response.result {
//                case .success(let JSON):
//                    print(JSON)
//                    self.saveData(datas:JSON as! [[String : Any]])
//                case .failure(let error):
//                    print("Request failed with error: \(error)")
//                    completionHandler(false,error)
//                }
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
