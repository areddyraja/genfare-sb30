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

class GFTicketCardSeletionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var saveCardButton: UIButton!
    
    var productsCartArray = [[String:Any]]()
    let viewModel = GFTicketCardsViewModel()
    let disposeBag = DisposeBag()
    var spinnerView:UIView?
    var baseClass:UIViewController?
    var card = [String:Any]()

    @IBOutlet var mailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        OrderProducts()
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
    @objc func saveCardCliked(sender: UIButton){
        
        if(sender.isSelected){
            sender.isSelected = false
          saveCardButton.setImage(UIImage(named: "ic_checkedbox"), for: .normal)
             UserDefaults.standard.set(true, forKey: "savedcards")
        }else{
            sender.isSelected = true
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
        return cell
    }
     @objc func deletecardCliked(sender: UIButton){
        card = viewModel.model[sender.tag] as! [String : Any]
        var cardNumber = card["cardNumber"] as? Int
        
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
        let navController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "GFPurchaseWebViewController") as? GFPurchaseWebViewController
      let  walletID =  GFWalletsService.walletID!
        var orderNumber =   UserDefaults.standard.integer(forKey: "orderNumber")
        var savedValue =   UserDefaults.standard.bool(forKey: "savedcards")
        let  url1 = "/services/data-api/mobile/payment/page?tenant=\(Utilities.tenantId())&orderId=\(orderNumber)&walletId=\(walletID)&saveForFuture=\(savedValue)"
        let url =  Utilities.apiHost()+url1
        navController?.weburl = url
       navigationController?.pushViewController(navController!, animated: true)
        
    }
    @IBAction func backToCartClicked(_ sender: Any) {
    }
}
