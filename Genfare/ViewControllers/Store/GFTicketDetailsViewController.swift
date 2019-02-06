//
//  GFTicketDetailsViewController.swift
//  Genfare
//
//  Created by omniwyse on 04/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFTicketDetailsViewController: GFBaseViewController,UITableViewDelegate,UITableViewDataSource {
    var seletedProducts = [[String:Any]]()
    var arrNotStoredProds = [[String:Any]]()
    var arrStoredProds  = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  seletedProducts.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .default, reuseIdentifier: "Identifier")
        
        let prodObj = seletedProducts[indexPath.row]
        
        
        var storedlabel = UILabel(frame: CGRect(x: 0, y: 5, width: cell.frame.size.width - 50, height: 20))
      //  storedlabel.text = selProductsArray[indexPath.row]["productDescription"] as? String
        if let font = UIFont(name: "Helvetica-Bold", size: 17) {
            storedlabel.font = font
        }
        storedlabel.numberOfLines = 0
        storedlabel.adjustsFontSizeToFitWidth = true
        storedlabel.minimumScaleFactor = 0.5
        if let riderText =  prodObj["productDescription"] as? String{
            storedlabel.text = riderText
        }
        cell.contentView.addSubview(storedlabel)
        
        var fare = prodObj["total_ticket_fare"] as? Float
        
        
        var storedlabel1 = UILabel(frame: CGRect(x: 0, y: 30, width: cell.frame.size.width - 50, height: 20))
        storedlabel1.text = String(format: " $ %.2f", fare!)
        storedlabel.numberOfLines = 0
        storedlabel.adjustsFontSizeToFitWidth = true
        storedlabel.minimumScaleFactor = 0.5
        cell.contentView.addSubview(storedlabel1)
        var storedlabel2 = UILabel(frame: CGRect(x: 0, y: 55, width: cell.frame.size.width - 50, height: 20))
        var ticketCountString = prodObj["ticket_count"] as? Int
        if (ticketCountString == 0) {
            var naStr = "NA"
            storedlabel2.text = " Quantity :  \(naStr)"
        } else {
            if let value = prodObj["ticket_count"] {
                storedlabel2.text = " Quantity :  \(value)"
            }
        }
        storedlabel.numberOfLines = 0
        storedlabel.adjustsFontSizeToFitWidth = true
        storedlabel.minimumScaleFactor = 0.5
        cell.contentView.addSubview(storedlabel2)
        var cancelButton = UIButton(frame: CGRect(x: 0, y: 5, width: 20, height: 20))
        cancelButton.tag = indexPath.row + 1
        let image = UIImage(named: "cancel") as UIImage?
        cancelButton.setImage(image, for: .normal)
       // cancelButton.addTarget(self, action: #selector(self.onClickofCancel(_:)), for: .touchUpInside)
        cell.accessoryView = cancelButton
        return cell
    }

    @IBAction func onClickOfAddMoreProducts(_ sender: UIButton) {
         self.navigationController?.popViewController(animated: true)
    }
    
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
    @IBAction func SecondContinuePressed(_ sender: Any) {
        if seletedProducts.count > 0{
            self.getSelectedProducts()
            let arrProductsList = self.getArrayOfProducts()
            if arrProductsList.count > 0{
                let navController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "GFTicketCardSeletionViewController") as? GFTicketCardSeletionViewController
                navController!.productsCartArray = arrProductsList
                navigationController?.pushViewController(navController!, animated: true)
            }
        }
    }
    
    func getSelectedProducts(){
        self.arrStoredProds.removeAll()
        self.arrNotStoredProds.removeAll()
        for prod in seletedProducts{
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
