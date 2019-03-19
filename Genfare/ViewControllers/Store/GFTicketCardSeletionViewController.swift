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
        // Do any additional setup after loading the view.
        if self.productsCartArray.count > 0{
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMailLabel()
        viewModel.fetchListOfCards()
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
        if let cardnumber =  card["lastFour"] as? String{
            cell.canrdNumberLabel.text = "\(cardnumber)"
       }
        if let cardImage = card["paymentTypeId"] as? Int{
       cell.Cardimage.image = UIImage(named: String(cardImage)) as UIImage? }
        else{
        cell.Cardimage.image = UIImage(named: "Card") as UIImage?
        }
        return cell
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
    @IBAction func backToCartClicked(_ sender: Any) {
    }
}
