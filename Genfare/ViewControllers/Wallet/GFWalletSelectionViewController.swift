//
//  GFWalletSelectionViewController.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFWalletSelectionViewController: GFBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createWalletBtn: UIButton!
    
    var walletList:Array<Any>?
    var walletID:NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    @IBAction override func dismissCurrent(_ sender: UIButton) {
        self.logoutUser()
        dismiss(animated: true, completion: nil)
    }
    func assignWallet(walletid:NSNumber){
        let walletService:GFAssignWalletService = GFAssignWalletService(walletID: walletid)
        walletService.assignWallet { [unowned self] (success, error) in
            if success {
                self.saveAssignedWallet()
                print("Successfully Assigned..!")
            }else{
                self.popupAlert(title: "Error", message: error as! String, actionTitles: ["OK"], actions: [nil])
            }
        }
    }
    
    func saveAssignedWallet() {
        let index = tableView.indexPathForSelectedRow?.row
        if let wallet = walletList?[index!] as? [String:Any] {
            GFWalletsService.saveWalletData(data: wallet)
            walletID = wallet["id"] as? NSNumber
            fetchProducts()
        }else{
            print("Problem saving wallet")
        }
    }
    
    func fetchWalletContents() {
        let wContents:GFWalletContentsService = GFWalletContentsService(walletID: walletID!)
        wContents.getWalletContents { [unowned self] (success, error) in
            if success {
                print("Got wallet contents successfully")
            }else{
                self.popupAlert(title: "Error", message: error as! String, actionTitles: ["OK"], actions: [nil])
            }
        }
    }
    
    func fetchProducts() {
        let products:GFFetchProductsService = GFFetchProductsService(walletID: walletID!)
        products.getProducts { [unowned self] (success, error) in
            if success {
                print("Got Product contents successfully")
                self.dismiss(animated: true, completion: nil)
                //self.fetchWalletContents()
            }else{
                self.popupAlert(title: "Error", message: error as! String, actionTitles: ["OK"], actions: [nil])
            }
        }
    }
    
    func gotoAccountHome() {
        
    }
}

extension GFWalletSelectionViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "walletcell")
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "walletcell")
        }
        let wallet:[String:Any] = ((walletList?[indexPath.row]) as? [String:Any])!
        cell!.textLabel?.text = wallet["nickname"] as! String
        return cell!
    }
}

extension GFWalletSelectionViewController :UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Show confirmation alert and assign wallet
        let wallet:[String:Any] = ((walletList?[indexPath.row]) as? [String:Any])!
        print(wallet)
        self.assignWallet(walletid: wallet["walletId"] as! NSNumber)
    }
}

