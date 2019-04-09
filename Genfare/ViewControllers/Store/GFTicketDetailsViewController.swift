//
//  GFTicketDetailsViewController.swift
//  Genfare
//
//  Created by omniwyse on 04/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFTicketDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let viewModel = GFTicketDetailsViewModel()
    var seletedProducts = [[String:Any]]()
    var spinnerView:UIView?
    
    @IBOutlet var productsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.seletedProductsModel = seletedProducts
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  viewModel.seletedProductsModel.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .default, reuseIdentifier: "Identifier")
        
        let prodObj = viewModel.seletedProductsModel[indexPath.row]
        
        
        var riderlabel = UILabel(frame: CGRect(x: 0, y: 5, width: cell.frame.size.width - 50, height: 20))
        if let font = UIFont(name: "Helvetica-Bold", size: 17) {
            riderlabel.font = font
        }
        if let riderText =  prodObj["productDescription"] as? String{
            riderlabel.text = riderText
        }
        cell.contentView.addSubview(riderlabel)
        
        var fare = prodObj["total_ticket_fare"]
        var pricelabel = UILabel(frame: CGRect(x: 0, y: 30, width: cell.frame.size.width - 50, height: 20))
        pricelabel.text = String(format: " $ %.2f", fare! as! CVarArg)
        cell.contentView.addSubview(pricelabel)
        var quantitylabel = UILabel(frame: CGRect(x: 0, y: 55, width: cell.frame.size.width - 50, height: 20))
        var ticketCountString = prodObj["ticket_count"] as? Int
        if (ticketCountString == 0) {
            var naStr = "NA"
            quantitylabel.text = " Quantity :  \(naStr)"
        } else {
            if let value = prodObj["ticket_count"] {
                quantitylabel.text = " Quantity :  \(value)"
            }
        }
        cell.contentView.addSubview(quantitylabel)
        var cancelButton = UIButton(frame: CGRect(x: 0, y: 5, width: 20, height: 20))
        cancelButton.tag = indexPath.row + 1
        let image = UIImage(named: "cancel") as UIImage?
        cancelButton.setImage(image, for: .normal)
       cancelButton.addTarget(self, action:#selector(onClickofCancel(sender:)), for: .touchUpInside)
        cell.accessoryView = cancelButton
        return cell
    }
    @objc func onClickofCancel(sender: GFMenuButton){
        viewModel.seletedProductsModel.remove(at: sender.tag - 1)
        productsTableView.reloadData()
    }


    @IBAction func onClickOfAddMoreProducts(_ sender: UIButton) {
         self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func SecondContinuePressed(_ sender: Any) {
        if viewModel.seletedProductsModel.count > 0{
            viewModel.getSelectedProducts()
            let arrProductsList = viewModel.getArrayOfProducts()
            if arrProductsList.count > 0{
                let navController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "GFTicketCardSeletionViewController") as? GFTicketCardSeletionViewController
                navController!.productsCartArray = arrProductsList
                navigationController?.pushViewController(navController!, animated: true)
            }
        }
    }
    

    
}
