//
//  GFLoginViewController.swift
//  Genfare
//
//  Created by omniwzse on 29/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFLoginViewController: GFBaseViewController {

    @IBOutlet weak var emailTxt: GFWhiteButtonTextField!
    @IBOutlet weak var passwordTxt: GFWhiteButtonTextField!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var signInBtn: GFMenuButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginUser(_ sender: UIButton) {
        
        guard emailTxt.text != "" else {
            popupAlert(title: "Alert", message: "eMail can not be empty", actionTitles: ["OK"], actions: [nil])
            return
        }

        guard passwordTxt.text != "" else {
            popupAlert(title: "Alert", message: "Password can not be empty", actionTitles: ["OK"], actions: [nil])
            return
        }
        
        if emailTxt.text == "1707@gmail.com" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let controller = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATETOSTORE") as? GFMyPassesViewController {
                let navController = UINavigationController(rootViewController: controller)
                appDelegate.window?.rootViewController = navController
            }
            self.dismiss(animated: false, completion: nil)
        }else{
            popupAlert(title: "Error", message: "Login failed", actionTitles: ["OK"], actions: [nil])
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
