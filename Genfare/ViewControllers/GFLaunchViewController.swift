//
//  GFLaunchViewController.swift
//  Genfare
//
//  Created by vishnu on 09/01/19.
//  Copyright © 2019 Genfare. All rights reserved.
//

import UIKit
import CoreData

class GFLaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     self.splashScreenImg.image =  UIImage(named: "\(Utilities.tenantId().lowercased())SplashScreen")
        let launchScreenViewModel = LaunchScreenViewModel()
        launchScreenViewModel.getAuthToken { [unowned self] (success, error) in
            if(success){
                print("got token")
            }
            self.gotoHomeScreen()
        }
    }
    @IBOutlet var splashScreenImg: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func gotoHomeScreen() {
        displayAccount()
        let mainStory = UIStoryboard(name: "Main", bundle: nil)
        let vc:HomeViewController = mainStory.instantiateViewController(withIdentifier: "GFNAVIGATEMENUHOME") as! HomeViewController
        let navController = UINavigationController(rootViewController: vc)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navController
    }
    
    func displayAccount() {
        
        if let account:Account = GFDataService.currentAccount() {
            print(account.emailaddress)
        }else{
            print("Account not found")
        }
    }
    
}
