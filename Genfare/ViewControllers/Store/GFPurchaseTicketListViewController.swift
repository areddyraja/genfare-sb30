//
//  GFPurchaseTicketListViewController.swift
//  Genfare
//
//  Created by omniwyse on 30/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFPurchaseTicketListViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    @IBOutlet var ProductsTableView: UITableView!
    var quantityValue = 0
    
    @IBOutlet var ContinueButton: GFMenuButton! //continueButton.
    @IBOutlet var MailLabel: UILabel!
    @IBOutlet var PayAsYouGoLabel: UILabel!
    @IBOutlet var DollarSymbolLabel: UILabel!
    @IBOutlet var PayAsYouGoTextField: UITextField!
    let viewModel = PurchaseTicketListViewModel()
    var totalProdcutArray = [AnyObject]()
    var fare = 0.0
    var walletMax = 0
    var walletMin = 0
    let disposeBag = DisposeBag()
    var spinnerView:UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        let configure:Configure = GFAccountManager.configuredValues()!
        walletMax = configure.configMax as! Int
        walletMin = configure.configMin as! Int
        self.ProductsTableView.reloadData()
        createCallbacks()
         ContinueButton.backgroundColor = UIColor.lightGray
      
        //createViewModelBinding()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.showProducts()
        updateMailLabel()
  
    }
    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ [unowned self] value in
                NSLog("Successfull \(value)")
                if value{
                    self.viewModel.targetMethod()
                    let payAsYouGoText =  self.viewModel.returnStoredValueWithActivation()
                    for i in payAsYouGoText{
                        self.PayAsYouGoLabel.text = i.productDescription
                    }
                }
            }.disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading.asObservable()
            .bind{[unowned self] value in
                NSLog("Loading \(value)")
                if value {
                    self.spinnerView = UIViewController.displaySpinner(onView: self.view)
                }else{
                    if let _ = self.spinnerView {
                        UIViewController.removeSpinner(spinner: self.spinnerView!)
                    }
                }
            }.disposed(by: disposeBag)
        
        // errors
        viewModel.errorMsg.asObservable()
            .bind {[unowned self] errorMessage in
                // Show error
                if errorMessage != ""{
                    print(errorMessage)
                }
            }.disposed(by: disposeBag)
    }
    func updateMailLabel() {
    let userAccount:Account? = GFAccountManager.currentAccount()
        guard userAccount?.emailaddress != nil else {
            return
        }
        MailLabel.text = String(format: "Welcome %@", (userAccount?.emailaddress)!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  viewModel.productsListArrayModel.count//products.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150.0;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ProductsTableView.dequeueReusableCell(withIdentifier: "PurchaseTicketTableViewCell", for: indexPath) as! PurchaseTicketTableViewCell
        
       // print("Obj is:\(viewModel.productsListArrayModel[indexPath.row])")
        let prodObj = viewModel.productsListArrayModel[indexPath.row]
        
        if let riderText =  prodObj["productDescription"] as? String{
            cell.RiderName.text = riderText
            cell.RiderTypeDesc.text = riderText
        }
        cell.PlusButton.tag = indexPath.row
        cell.MinusButton.tag = indexPath.row
        cell.MinusButton.addTarget(self, action: #selector(minusbuttonCliked(sender:)), for: .touchUpInside)
        cell.PlusButton.addTarget(self, action: #selector(plusbuttonClicked(sender:)), for: .touchUpInside)
        let ticketCount   = prodObj["ticket_count"] as! Int
        cell.TicketCount.text = String(ticketCount)
        if let fare = prodObj["price"] as? String{
            cell.TicketAmount.text = String(format: "Fare $%@.00",fare)
        }
        
        if let individualFare = prodObj["total_ticket_fare"] as? Float{
            cell.TotalTicketFare.text = String(describing: individualFare)
        }
        
        return cell
    }
    
    
   
    func dictForPayAsYouGo() {
        viewModel.payAsYouGoTextFieldtext = self.PayAsYouGoTextField.text!
        UserDefaults.standard.set(viewModel.payAsYouGoTextFieldtext, forKey: "payasyougoamount")
    }
    //
  
 
    @objc func minusbuttonCliked(sender: GFMenuButton){
        if let dictObj = viewModel.productsListArrayModel[sender.tag] as? AnyObject{
            if let convertDict = dictObj as? Dictionary<String, Any>{
                quantityValue = convertDict["ticket_count"] as! Int
                if(quantityValue>=1){
                    quantityValue = quantityValue - 1
                    }
                let price = convertDict["price"] as! String
                let fare =  Float(quantityValue) * Float(price)!
                var Newdict: [AnyHashable : Any] = [:]
                var temp = NSMutableDictionary(dictionary: Newdict);
                Newdict.merge(dict: convertDict)
                Newdict["ticket_count"] = quantityValue
                Newdict["total_ticket_fare"] = fare
                viewModel.productsListArrayModel[sender.tag] = Newdict as! [String : Any]
            }
            validations()
        }
        self.ProductsTableView.reloadData()
        
    }
    @objc func plusbuttonClicked(sender: GFMenuButton){
        
        if let dictObj = self.viewModel.productsListArrayModel[sender.tag] as? AnyObject{
            if let convertDict = dictObj as? Dictionary<String, Any>{
                
                if let count = convertDict["ticket_count"] as? Int{
                    quantityValue = count + 1
                    
                }
                let price = convertDict["price"] as! String
                let fare =  Float(quantityValue) * Float(price)!
                var Newdict: [AnyHashable : Any] = [:]
                var temp = NSMutableDictionary(dictionary: Newdict);
                Newdict.merge(dict: convertDict)
                Newdict["ticket_count"] = quantityValue
                Newdict["total_ticket_fare"] = fare
                viewModel.productsListArrayModel[sender.tag] = Newdict as! [String : Any]
            }
            validations()
        }
        self.ProductsTableView.reloadData()
        
    }
    func validations(){
        
        let totalAmount = viewModel.getTotalAmountforvalidations()
        
        if(totalAmount > walletMax){
            let alert = UIAlertController(title: "Maximum cart value exceeded", message: (String(format:"You can't add more than $%d to your cart.",walletMax)), preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { [unowned self] action in
            }))
            ContinueButton.backgroundColor = UIColor.lightGray
            ContinueButton.isUserInteractionEnabled = false
            
            // show the alert
            present(alert, animated: true, completion: nil)
        }
        else if(totalAmount < walletMin){
            let alert = UIAlertController(title:Utilities.stringResourceForId(resourceId:"Min_value")!, message:(String(format: "You cannot add less than $%d to your cart.",walletMin)), preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: Utilities.stringResourceForId(resourceId:"close"), style: UIAlertAction.Style.cancel, handler: { [unowned self] action in
            }))
            
            ContinueButton.backgroundColor = UIColor.lightGray
            ContinueButton.isUserInteractionEnabled = false
            // show the alert
            present(alert, animated: true, completion: nil)
            
        }
        else{
            ContinueButton.isUserInteractionEnabled = true
            ContinueButton.backgroundColor =  UIColor(hexString:" #E9AE0E")
        }
    }
    
    @IBAction func firstPageContinueButtonClicked(_ sender: GFMenuButton) {
        dictForPayAsYouGo()
        validations()
        viewModel.payasyougo()
        var seletedArraypayasyougo = [[String:Any]]()
        for j in 0..<viewModel.productsListArrayPayAsYouGoModel.count {
            seletedArraypayasyougo.append(viewModel.productsListArrayPayAsYouGoModel[j] as! [String : Any])
        }
        let newarray = seletedArraypayasyougo + viewModel.seletedArray
        let navController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "GFTicketDetailsViewController") as? GFTicketDetailsViewController
        let ticketViewModel = GFTicketDetailsViewModel()
        ticketViewModel.seletedProductsModel = newarray
        navController!.seletedProducts = newarray
        navigationController?.pushViewController(navController!, animated: true)
    }
    func textFieldShouldReturn(_ PayAsYouGoTextField: UITextField) -> Bool {
        
        PayAsYouGoTextField.resignFirstResponder()
        return true
    }
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if((textField.text?.isEmpty)!){
        ContinueButton.backgroundColor = UIColor.lightGray
        ContinueButton.isUserInteractionEnabled = false
    }
    else{
        ContinueButton.isUserInteractionEnabled = true
        ContinueButton.backgroundColor =  UIColor(hexString:" #E9AE0E")
    }
        return true
    }
}
    


extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

