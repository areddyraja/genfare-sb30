//
//  GFTicketCardSeletionViewController.swift
//  Genfare
//
//  Created by omniwyse on 05/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFTicketCardSeletionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,WalletProtocol {
    @IBOutlet var savedCrdLbl: UILabel!
    @IBOutlet var continueBtn: GFMenuButton!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var imgCardBtn: UIButton!
    @IBOutlet var saveCardButton: UIButton!
    
    var productsCartArray = [[String:Any]]()
    let viewModel = GFTicketCardsViewModel()
    let disposeBag = DisposeBag()
    var spinnerView:UIView?
    var baseClass:UIViewController?
    var card = [String:Any]()
    var selectedIndex = -1
   var isSelectedBtnImageCard = false
    @IBOutlet var selectedImg: UIImageView!
    @IBOutlet var mailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCallbacks()
         saveCardButton.setImage(UIImage(named: "ic_uncheckedbox"), for: .normal)
        saveCardButton.addTarget(self, action: #selector(saveCardCliked(sender:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
        if self.productsCartArray.count > 0{
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMailLabel()
        viewModel.fetchListOfCards()
    }
    
    @IBAction func imgCardBtnTapped(_ sender: UIButton) {
        if(sender.isSelected){
            sender.isSelected = false
            imgCardBtn.backgroundColor = UIColor(hexString:"#d1d1d1")
            
        }else{
            sender.isSelected = true
            imgCardBtn.backgroundColor = UIColor(hexString:"#808080")
            selectedIndex = -1
            self.tableView.reloadData()
        }
        
       
  }
    @objc func saveCardCliked(sender: UIButton){
        
        if(sender.isSelected){
            isSelectedBtnImageCard = false
          saveCardButton.setImage(UIImage(named: "ic_checkedbox"), for: .normal)
             UserDefaults.standard.set(true, forKey: "savedcards")
        }else{
            isSelectedBtnImageCard = true
            saveCardButton.setImage(UIImage(named: "ic_uncheckedbox"), for: .normal)
             UserDefaults.standard.set(false, forKey: "savedcards")
        }
    }
    
    
    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ [unowned self] value in
                NSLog("Successfull \(value)")
                if value{
                    self.tableView.reloadData()
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
        mailLabel.text = userAccount?.emailaddress
    }
    
    func OrderProducts() {
        let orderedService = GFCreateOrderForProductsService(order:productsCartArray, walletID: self.walledId())
        orderedService.createOrderService { (success,error) in
            if success! {
                print("ordered")
                if(self.selectedIndex != -1){
                    let navController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "GFPurchaseWebViewController") as? GFPurchaseWebViewController

                    let  walletID =  self.walledId()
                    let orderNumber =   UserDefaults.standard.integer(forKey: "orderNumber")

                    let savedValue =   UserDefaults.standard.bool(forKey: "savedcards")
                    self.card = self.viewModel.model[self.selectedIndex] as! [String : Any]
                    let url1   = "/services/data-api/mobile/payment/page?tenant=\(Utilities.tenantId())&orderId=\(orderNumber)&walletId=\(walletID)&savedCardId=\(self.card["cardNumber"]!)"
                    let url =  Utilities.apiHost()+url1
                    navController?.weburl = url
                    self.navigationController?.pushViewController(navController!, animated: true)
                }
                self.pushToWebPage()
            }
            else{
                print("error")
            }
            
        }

    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.model.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? SavedCardsListTableViewCell else { return UITableViewCell()}
        card = viewModel.model[indexPath.row] as? [String: Any] ?? [:]
        cell.CardBgview.layer.cornerRadius = 5.0
        cell.CardBgview.layer.borderWidth = 2.0
        cell.CardBgview.clipsToBounds = true
       cell.CardBgview.layer.borderColor = UIColor(hexString:"#d1d1d1").cgColor
        cell.CardBgview.backgroundColor = UIColor(hexString:"#d1d1d1")
        cell.deleteButton.tag = indexPath.row
        cell.backgroundColor = UIColor.clear

         cell.deleteButton.addTarget(self, action: #selector(deletecardCliked(sender:)), for: .touchUpInside)
        if let cardnumber =  card["lastFour"] as? String{
            cell.canrdNumberLabel.text = "\(cardnumber)"
       }
        if let cardImage = card["paymentTypeId"] as? Int{
       cell.Cardimage.image = UIImage(named: String(cardImage)) as UIImage?

        }

        else{
        cell.Cardimage.image = UIImage(named: "Card") as UIImage?
        }
        if(selectedIndex == indexPath.row){
            cell.backgroundColor = UIColor(hexString:"#808080")
        }
        return cell
    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
  
        selectedIndex = indexPath.row
        imgCardBtn.backgroundColor = UIColor(hexString:"#d1d1d1")
               self.tableView.reloadData()
    
       
    }
    
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell:SavedCardsListTableViewCell = tableView.cellForRow(at: indexPath) as! SavedCardsListTableViewCell
         cell.backgroundColor = UIColor(hexString:"#808080")
    }
     @objc func deletecardCliked(sender: UIButton){
        card = viewModel.model[sender.tag] as! [String : Any]
        let cardNumber = card["cardNumber"] as? Int
        
        let alert = UIAlertController(title: "Delete Card", message: "Are you sure to delete this card", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "no", style: UIAlertAction.Style.cancel, handler: { [unowned self] action in
            

            
        }))
        alert.addAction(UIAlertAction(title: "yes", style: UIAlertAction.Style.destructive, handler: { [unowned self] action in
           
            let deleteCard:GFDeleteCardService = GFDeleteCardService(cardNumber: cardNumber!)
            deleteCard.deleteCard{ (success,error) in
                if success {
                   self.tableView.reloadData()
                }else{
//                     self.popupAlert(title: "Error", message: self.viewModel.formErrorString(), actionTitles: ["OK"], actions: [nil])
                }
            }
        
            
        }))
        
        // show the alert
        present(alert, animated: true, completion: nil)
    }

    @IBAction func paymentButtonPressed(_ sender: Any) {
        if(selectedIndex != -1){
           let existingPassword = String(describing: KeychainWrapper.standard.string(forKey: Constants.KeyChain.Password)!)
              let email = (String(describing: KeychainWrapper.standard.string(forKey: Constants.KeyChain.UserName)!))
            let alert = UIAlertController(title: "Saved Credit Card", message: (String(format:"Enter the password for %@ to use saved cards.\n\nOnce the password is verified, this card will be used for further Payment",email)), preferredStyle: UIAlertController.Style.alert)
            
            
            alert.addTextField { (textField) -> Void in
                let  passwordTextField = textField
                passwordTextField.delegate = self 
                passwordTextField.placeholder = "Password"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "verify", style: UIAlertAction.Style.destructive, handler: { action in
                let passwordText = alert.textFields![0]
                if(passwordText.text == existingPassword){
                    self.OrderProducts()
                }
                else{
                    let alert = UIAlertController(title: "Password", message: "Please provide correct password", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
            self.OrderProducts()
    
        
        
    }
    func pushToWebPage(){
        let navController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "GFPurchaseWebViewController") as? GFPurchaseWebViewController
        
        let  walletID =  self.walledId()
        let orderNumber =   UserDefaults.standard.integer(forKey: "orderNumber")
        let savedValue =   UserDefaults.standard.bool(forKey: "savedcards")
        let  url1 = "/services/data-api/mobile/payment/page?tenant=\(Utilities.tenantId())&orderId=\(orderNumber)&walletId=\(walletID)&saveForFuture=\(savedValue)"
        let url =  Utilities.apiHost()+url1
        navController?.weburl = url
        navigationController?.pushViewController(navController!, animated: true)
    }
    
    @IBAction func backToCartClicked(_ sender: Any) {
    }
}
