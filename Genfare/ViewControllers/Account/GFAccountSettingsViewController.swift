//
//  AccountSettingsViewController.swift
//  Genfare
//
//  Created by omniwyse on 08/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFAccountSettingsViewController: UIViewController {

    @IBAction func changeEmailClicked(_ sender: UIButton) {
        
        if let navController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "GFChangeEmailViewController") as? GFChangeEmailViewController {
            if let navigator = navigationController {
                navigator.pushViewController(navController, animated: false)
            }
        }
        
    }
    @IBAction func changePasswordClicked(_ sender: UIButton) {
        
        if let navController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "GFChangePasswordViewController") as? GFChangePasswordViewController {
            if let navigator = navigationController {
                navigator.pushViewController(navController, animated: false)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
