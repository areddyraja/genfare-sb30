//
//  GFBaseViewController.swift
//  Genfare
//
//  Created by omniwzse on 28/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import SideMenu

@objc class GFBaseViewController: UIViewController {
    
    var currentTextField:UITextField?
    
    @IBOutlet weak var navBarLogo: UIImageView!
    @IBOutlet weak var topNavBar: UIView!
    
    @objc var managedObjectContext:NSManagedObjectContext?
    @objc static var currentMenuItem:String = Constants.SideMenuAction.PlanTrip
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.Login), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.HomeScreen), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(showUserLogin(notification:)), name: Notification.Name(Constants.NotificationKey.Login), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gotoRootController(notification:)), name: Notification.Name(Constants.NotificationKey.HomeScreen), object: nil)
        
        self.navBarLogo.image = UIImage.init(named: String.init(format: "%@NavBarLogo",Utilities.tenantId()?.lowercased() ?? ""))

        self.navBarLogo.backgroundColor = UIColor.clear
        topNavBar.backgroundColor = UIColor.colorForString(str: "NavBarColor")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.topNavBarColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view?.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    func openSideMenu () {
        if let controller = UIStoryboard(name: "Sidemenu", bundle: nil).instantiateInitialViewController() as? UISideMenuNavigationController {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func gotoRootController(notification:Notification) {
        goToRoot(UIButton())
    }
    
    @objc func showUserLogin(notification:Notification) {
        let singlet:Singleton = Singleton.sharedManager() as! Singleton
        let controller:SignInViewController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        controller.managedObjectContext = singlet.managedContext
        let navController:UINavigationController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    @objc func navigateToPasses() -> Void {
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.PassPurchase {
            presentedViewController?.navigationController?.popToRootViewController(animated: false)
            return
        }
        
        if shouldShowLogin() {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.NotificationKey.Login)))
            return
        }
        
        showAccountHome()
    }
    
    func shouldShowLogin() -> Bool {
        let baseService = BaseService()
        let userAccount:Account? = baseService.currentUserAccount()
        
        guard userAccount != nil else {
            print("User account is nil")
            return true
        }
        
        guard userAccount?.emailaddress != nil else {
            return true
        }
        
        return false
    }

    func showAccountHome() {
        let singlet:Singleton = Singleton.sharedManager() as! Singleton
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let controller:HomeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        controller.managedObjectContext = singlet.managedContext
        let navController = UINavigationController(rootViewController: controller)
        appDelegate.window?.rootViewController = navController
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.PassPurchase
    }

    deinit {
        print("Controller is being removed -============================================== \(self)")
    }
}

extension GFBaseViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKey.SideMenuVisible), object: nil)
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
