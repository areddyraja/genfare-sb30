//
//  SideMenuItemsViewController.swift
//  Genfare
//
//  Created by omniwzse on 21/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class SideMenuItemsViewController: UIViewController {

    @IBOutlet weak var menuHomeScreen: UIButton!
    @IBOutlet weak var menuPlanTrip: UIButton!
    @IBOutlet weak var menuPassPurchase: UIButton!
    @IBOutlet weak var menuSettings: UIButton!
    @IBOutlet weak var menuLogin: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func homeButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKey.HomeScreen), object: nil)
    }
    
    @IBAction func planTrip(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKey.PlanTrip), object: nil)
    }
    
    @IBAction func showPasses(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKey.PassPurchase), object: nil)
    }

    @IBAction func showSettings(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKey.Settings), object: nil)
    }
    
    @IBAction func userLogin(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(Constants.NotificationKey.Login), object: nil)
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
