//
//  GFSideMenuItemsViewController.swift
//  CDTATicketing
//
//  Created by omniwzse on 10/10/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

import UIKit
import SideMenu

class GFSideMenuItemsViewController: UIViewController {

    @IBOutlet weak var menuHomeScreen: UIButton!
    @IBOutlet weak var menuPlanTrip: UIButton!
    @IBOutlet weak var menuPassPurchase: UIButton!
    @IBOutlet weak var menuSettings: UIButton!
    @IBOutlet weak var menuLogin: UIButton!
    @IBOutlet weak var menuAlerts: UIButton!
    @IBOutlet weak var menuContactus: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    var presentedController:UIViewController?
    var currentAction:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.SideMenuVisible), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.LoginSuccessful), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Constants.NotificationKey.Logout), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(sideMenuShown(notification:)), name: Notification.Name(Constants.NotificationKey.SideMenuVisible), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoginSuccess(notification:)), name: Notification.Name(Constants.NotificationKey.LoginSuccessful), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogoutSuccess(notification:)), name: Notification.Name(Constants.NotificationKey.Logout), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentedController = self.presentedViewController
        updateSideMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func sideMenuShown(notification:Notification) {
        print("Side menu shown")
        updateSideMenu()
    }
    
    @objc func navigateToHome() {
        print("SIDEMENU - Home")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.HomeScreen {
            presentedViewController?.navigationController?.popToRootViewController(animated: false)
            return
        }
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEMENUHOME") as? GFMapsHomeViewController {
            attachControllerToMainWindow(controller: controller)
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.HomeScreen
    }
    
    @objc func navigateToPlanTrip() {
        print("SIDEMENU - Plan Trip")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.PlanTrip {
            presentedViewController?.navigationController?.popToRootViewController(animated: false)
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.NotificationKey.HomeScreen)))
            return
        }

        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEMENUHOME") as? GFMapsHomeViewController {
            attachControllerToMainWindow(controller: controller)
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.PlanTrip
    }
    
    @objc func navigateToPasses() {
        print("SIDEMENU - My Passes")
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
    
    @objc func navigateToLogin() {
        print("SIDEMENU - Login")
        if shouldShowLogin() {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.NotificationKey.Login)))
            return
        }
        showLogoutAlert()
    }
    
    @objc func confirmLogout() -> Void {
        let singleton:Singleton = Singleton.sharedManager() as! Singleton
        singleton.logOutHandler()
        
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.PlanTrip {
            presentedViewController?.navigationController?.popToRootViewController(animated: false)
            return
        }
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEMENUHOME") as? GFMapsHomeViewController {
            attachControllerToMainWindow(controller: controller)
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.PlanTrip
    }

    @objc func navigateToAlerts() -> Void {
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.Alerts {
            presentedViewController?.navigationController?.popToRootViewController(animated: false)
            return
        }
        
        if let controller = AlertsViewController(nibName: "AlertsViewController", bundle: nil) {
            let singlet:Singleton = Singleton.sharedManager() as! Singleton
            controller.managedObjectContext = singlet.managedContext
            attachControllerToMainWindow(controller: controller)
        }
        
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.Alerts
    }
    
    @objc func navigateToSettings() -> Void {
        print("SIDEMENU - Settings")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.Settings {
            navigationController?.popToRootViewController(animated: false)
            return
        }
        if shouldShowLogin() {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.NotificationKey.Login)))
            return
        }
        showSettings()
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.Settings
    }

    @objc func navigateToContactus() -> Void {
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.ContactUs {
            presentedViewController?.navigationController?.popToRootViewController(animated: false)
            return
        }
        
        let nibName:String = Utilities.helpViewController()
        if let controller = HelpViewController(nibName: nibName, bundle: nil) {
            let singlet:Singleton = Singleton.sharedManager() as! Singleton
            controller.managedObjectContext = singlet.managedContext
            attachControllerToMainWindow(controller: controller)
        }
        
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.ContactUs
    }
    
    func updateSideMenu() {
        let baseService = BaseService()
        let userAccount:Account? = baseService.currentUserAccount()
        
        showLoginButton(status: true)
        guard userAccount != nil else {
            print("User account is nil")
            return
        }
        guard userAccount?.emailaddress != nil else {
            return
        }
        
        showLoginButton(status: false)
        userNameLabel.text = userAccount?.firstName
        emailLabel.text = userAccount?.emailaddress
    }
    
    @IBAction func homeButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func planTrip(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.PlanTrip
        dismiss(animated: false) {
            self.navigateToPlanTrip()
        }
    }
    
    @IBAction func showPasses(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.PassPurchase
        dismiss(animated: false){
            self.navigateToPasses()
        }
    }
    
    @IBAction func showAlerts(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.Alerts
        dismiss(animated: false){
            self.navigateToAlerts()
        }
    }

    @IBAction func showContactus(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.ContactUs
        dismiss(animated: false) {
            self.navigateToContactus()
        }
    }

    @IBAction func showSettings(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.Settings
        dismiss(animated: false) {
            self.navigateToSettings()
        }
    }
    
    @IBAction func userLogin(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.Login
        dismiss(animated: false) {
            self.navigateToLogin()
        }
    }
    
    func showSettings() {
        let singlet:Singleton = Singleton.sharedManager() as! Singleton
        if let controller:AccountSettingsViewController = AccountSettingsViewController(nibName: "AccountSettingsViewController", bundle: nil) {
            controller.managedObjectContext = singlet.managedContext
            attachControllerToMainWindow(controller: controller)
            GFBaseViewController.currentMenuItem = Constants.SideMenuAction.Settings
        }else{
            popupAlert(title: "ERROR", message: "Settings Screen not found", actionTitles: ["OK"], actions: [nil])
        }
    }
    
    func showAccountHome() {
        let singlet:Singleton = Singleton.sharedManager() as! Singleton
        let controller:HomeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        controller.managedObjectContext = singlet.managedContext
        attachControllerToMainWindow(controller: controller)
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.PassPurchase
    }

    func showLoginButton(status:Bool) {
        if status {
            menuLogin.setTitle("Log In", for: .normal)
            menuLogin.setImage(UIImage(named: "sign-in-alt-light"), for: .normal)
        }else {
            menuLogin.setTitle("Log Out", for: .normal)
            menuLogin.setImage(UIImage(named: "sign-out-alt-light"), for: .normal)
        }
    }
    
    @objc func handleLoginSuccess(notification:Notification) {
        switch currentAction {
        case Constants.SideMenuAction.Login:
            showAccountHome()
        case Constants.SideMenuAction.PassPurchase:
            showAccountHome()
        case Constants.SideMenuAction.Settings:
            showSettings()
        default:
            print("default")
        }
    }

    @objc func handleLogoutSuccess(notification:Notification) {
        navigateToPlanTrip()
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
    
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        let app = UIApplication.shared
        app.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showLogoutAlert() -> Void {
        // create the alert
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.destructive, handler: { action in
            
            self.confirmLogout()
            
        }))
        
        let windows = UIApplication.shared.windows
        let mainWindow = windows.first
        
        // show the alert
        topViewController(mainWindow?.rootViewController)!.present(alert, animated: true, completion: nil)
        //present(alert, animated: true, completion: nil)
    }
    
    func attachControllerToMainWindow(controller:UIViewController) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let subviews = appDelegate.window.subviews

//        if let transitionViewClass = NSClassFromString("UILayoutContainerView") {
//            for subview in subviews where subview.isKind(of: transitionViewClass) {
//                subview.removeFromSuperview()
//            }
//        }
//        DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.01) {
//            let navController = UINavigationController(rootViewController: controller)
//            appDelegate.window?.rootViewController = navController
//            appDelegate.window.makeKeyAndVisible()
//        }
        let navController = UINavigationController(rootViewController: controller)
        appDelegate.window?.rootViewController = navController
        appDelegate.window.makeKeyAndVisible()

    }
    
    func topViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        if rootViewController?.presentedViewController == nil {
            return rootViewController
        }
        
        if type(of: rootViewController?.presentedViewController) == UINavigationController.self {
            let navigationController = rootViewController?.presentedViewController as? UINavigationController
            let lastViewController: UIViewController? = navigationController?.viewControllers.last
            return topViewController(lastViewController)
        }
        
        let presentedViewController = rootViewController?.presentedViewController as? UIViewController
        return topViewController(presentedViewController)
    }
}
