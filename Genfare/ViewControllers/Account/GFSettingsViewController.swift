//
//  GFSettingsViewController.swift
//  Genfare
//
//  Created by omniwzse on 04/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFSettingsViewController: GFBaseViewController {

    
    @IBOutlet weak var walletIDTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "GFAccountSettingsViewController") as? GFAccountSettingsViewController {
            if let navigator = navigationController {
                navigator.pushViewController(navController, animated: false)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fetchWallets(_ sender: Any) {
        let walletService = GFCheckWalletService()
        walletService.fetchWallets { (result, error) in
            print(result)
        }
    }

    @IBAction func getEncryptionKeys(_ sender: Any){
        let encryptionkeys = GFEncryptionKeysService()
        encryptionkeys.fetchEncryptionKeys { (success, error) in
            if success {
                print("got keys")
            }
            else{
                print(error)
            }
        }
        
    }
    
    @IBAction func getAccountBalance(_ sender: Any)  {
        GFAccountBalanceService.fetchAccountBalance{ (success, error) in
            if success {
                print("got balance")
            }else{
                print(error)
            }
        }
    }
    
    @IBAction func getConfigApi(_ sender: Any){
        let configValues = GFConfigService()
        configValues.fetchConfigurationValues { (success,error) in
            if success! {
                print("configured")
            }
            else{
                print("error")
            }
            
        }
    }
    
    @IBAction func fetchWalletContents(_ sender: Any){
        let walletid = NSNumber(value: Int(walletIDTxt.text!)!)

        let configValues:GFWalletContentsService = GFWalletContentsService(walletID: walletid)
        configValues.getWalletContents { (success,error) in
            if success {
                print("got contents")
            }else{
                print("error")
            }
        }
    }

    @IBAction func releaseWallet(_ sender: Any){
        let walletid = NSNumber(value: Int(walletIDTxt.text!)!)
        let configValues = GFReleaseWalletService(walletID: walletid)
        configValues.releaseWallet { (success,error) in
            if success {
                print("released")
            }
            else{
                print("error")
            }
            
        }
    }

    @IBAction func fetchTickets(_ sender: Any){
        let walletid = GFWalletsService.walletID
        let tickets = GFTicketsService(walletID: walletid!)
        tickets.fetchTickets { (success,error) in
            if success {
                print("released")
            }
            else{
                print("error")
            }
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
