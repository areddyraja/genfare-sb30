//
//  GFSignupViewController.swift
//  Genfare
//
//  Created by omniwzse on 04/10/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFSignupViewController: GFBaseViewController, UITableViewDelegate {

    @IBOutlet weak var firstNameTxt: GFWhiteButtonTextField!
    @IBOutlet weak var lastNameTxt: GFWhiteButtonTextField!
    @IBOutlet weak var passwordTxt1: GFWhiteButtonTextField!
    @IBOutlet weak var passwordTxt2: GFWhiteButtonTextField!
    @IBOutlet weak var emailTxt: GFWhiteButtonTextField!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpUser(_ sender: UIButton) {
        
        guard firstNameTxt.text != "" else {
            popupAlert(title: "Alert", message: "First Name can not be empty", actionTitles: ["OK"], actions: [nil])
            return
        }
        
        guard lastNameTxt.text != "" else {
            popupAlert(title: "Alert", message: "Last Name can not be empty", actionTitles: ["OK"], actions: [nil])
            return
        }
        
        guard emailTxt.text != "" else {
            popupAlert(title: "Alert", message: "eMail can not be empty", actionTitles: ["OK"], actions: [nil])
            return
        }
        
        guard passwordTxt1.text != "" else {
            popupAlert(title: "Alert", message: "Password can not be empty", actionTitles: ["OK"], actions: [nil])
            return
        }
        
        guard passwordTxt1.text == passwordTxt2.text else {
            popupAlert(title: "Alert", message: "Password can not be empty", actionTitles: ["OK"], actions: [nil])
            return
        }
        
        popupAlert(title: "Error", message: "Registration failed", actionTitles: ["OK"], actions: [nil])

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
