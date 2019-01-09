//
//  GFBaseViewController.swift
//  Genfare
//
//  Created by omniwzse on 28/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import SideMenu

class GFBaseViewController: UIViewController {

    var currentTextField:UITextField?
    static var currentMenuItem:String = Constants.SideMenuAction.HomeScreen
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addMenuObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
       view.backgroundColor = UIColor.clear
      //  view.backgroundColor =  UIColor.colorFromHexString(hexString:  GFUtilities.sharedResource().colorHexString(fromId: GFUtilities.sharedResource().bgcolor()), withAlpha: 1.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view?.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func updateUIFortenant() {
        
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goToRoot(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func dismissCurrent(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func addMenuObservers() {
        print("Add MENU Observers")

        //Prevent adding observers multipletimes
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.HomeScreen), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.PlanTrip), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.PassPurchase), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.Settings), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.Login), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToHome(notification:)), name: Notification.Name(Constants.NotificationKey.HomeScreen), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToPlanTrip(notification:)), name: Notification.Name(Constants.NotificationKey.PlanTrip), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToPasses(notification:)), name: Notification.Name(Constants.NotificationKey.PassPurchase), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToSettings(notification:)), name: Notification.Name(Constants.NotificationKey.Settings), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToLogin(notification:)), name: Notification.Name(Constants.NotificationKey.Login), object: nil)
    }
    
    @objc func navigateToHome(notification:Notification) {
        print("SIDEMENU - Home")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.HomeScreen {
            navigationController?.popToRootViewController(animated: false)
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEMENUHOME") as? HomeViewController {
            let navController = UINavigationController(rootViewController: controller)
            appDelegate.window?.rootViewController = navController
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.HomeScreen
    }
    
    @objc func navigateToPlanTrip(notification:Notification) {
        print("SIDEMENU - Plan Trip")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.PlanTrip {
            navigationController?.popToRootViewController(animated: false)
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEMENUHOME") as? HomeViewController {
            let navController = UINavigationController(rootViewController: controller)
            appDelegate.window?.rootViewController = navController
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.PlanTrip
    }
    
    @objc func navigateToPasses(notification:Notification) {
        print("SIDEMENU - My Passes")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.PassPurchase {
            navigationController?.popToRootViewController(animated: false)
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let controller = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATETOSTORE") as? GFMyPassesViewController {
            let navController = UINavigationController(rootViewController: controller)
            appDelegate.window?.rootViewController = navController
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.PassPurchase
    }
    
    @objc func navigateToSettings(notification:Notification) {
        print("SIDEMENU - Settings")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.Settings {
            navigationController?.popToRootViewController(animated: false)
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let controller = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEMENUSETTINGS") as? GFSettingsViewController {
            let navController = UINavigationController(rootViewController: controller)
            appDelegate.window?.rootViewController = navController
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.Settings
    }
    
    @objc func navigateToLogin(notification:Notification) {
        print("SIDEMENU - Login")
//        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.Login {
//            navigationController?.popToRootViewController(animated: false)
//            return
//        }

//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let controller = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATETOLOGIN") as? GFLoginViewController {
            let navController = UINavigationController(rootViewController: controller)
//            appDelegate.window?.rootViewController = navController
            present(navController, animated: true, completion: nil)
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.Login
    }
    
    /*
    // MARK: - Navigation
     
     if let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEHOME") as? NavigateViewController {
     if let navigator = navigationController {
     navigator.pushViewController(navController, animated: false)
     }
     }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        print("Controller is being removed -============================================== \(self)")
        
    }
}

extension GFBaseViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension GFBaseViewController {
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
