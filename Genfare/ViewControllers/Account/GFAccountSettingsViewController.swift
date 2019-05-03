//
//  AccountSettingsViewController.swift
//  Genfare
//
//  Created by omniwyse on 08/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFAccountSettingsViewController: UIViewController,UITextFieldDelegate {
    
    
   
    
    @IBOutlet var homeAddressFld: UITextField!
    @IBOutlet var workAddreessFld: UITextField!
    @IBOutlet var schoolAddressFld: UITextField!
    @IBOutlet weak var topNavBar: UIView!
    @IBOutlet weak var navBarLogo: UIImageView!
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
        loadSavedAddress()
        self.homeAddressFld.delegate = self
        self.workAddreessFld.delegate = self
        self.schoolAddressFld.delegate = self
        self.navBarLogo.image = UIImage.init(named: String.init(format: "%@NavBarLogo",Utilities.tenantId().lowercased() ?? ""))
        self.navBarLogo.backgroundColor = UIColor.clear
        topNavBar.backgroundColor = UIColor.topNavBarColor
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       // let storredAddress:StorredAddress = self.StorredAddress()
        if textField == homeAddressFld {
        
            self.showAddressEditor(for: "home")
        } else if textField == workAddreessFld {
          
            self.showAddressEditor(for: "work")
        } else if textField == schoolAddressFld {
            
          self.showAddressEditor(for: "school")
        }
        return false
    
    }
    
 //   func StorredAddress() ->StorredAddress {
  //      let records:StorredAddress = GFDataService.fetchRecords(entity: "StorredAddress")
   //     return records
    //}
    override func viewWillAppear(_ animated: Bool) {
         loadSavedAddress()
    }
    func loadSavedAddress()  {
        
        let storedaddresses = GFDataService.getAddress()!
        let homemodel:Array<StoredAddress>? = storedaddresses.filter{ ($0.type as? String) == "home" && ($0.name as? String) != nil}
        let workmodel:Array<StoredAddress>? = storedaddresses.filter{ ($0.type as? String) == "work" && ($0.name as? String) != nil}
        let schoolmodel:Array<StoredAddress>? = storedaddresses.filter{ ($0.type as? String) == "school" && ($0.name as? String) != nil}
       
          if homemodel?.count != 0{
             let home:StoredAddress = (homemodel?.first)!
            self.homeAddressFld.text = home.name
        }
        else{
            self.homeAddressFld.text = ""
        }
        if workmodel?.count != 0{
             let work:StoredAddress = (workmodel?.first)!
            self.workAddreessFld.text = work.name
        }else{
            self.workAddreessFld.text = ""
        }
        if schoolmodel?.count != 0{
            let school:StoredAddress = (schoolmodel?.first)!
            self.schoolAddressFld.text = school.name
        }else{
            self.schoolAddressFld.text = ""
        }
    }
    
    func getAddressFrom(_ str: String?) -> String? {
        let items = str?.components(separatedBy: "|")
        return items?.first
    }
    
    func showAddressEditor(for key: String?) {
        
        if let navController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "GFSaveAddressViewController") as? GFSaveAddressViewController {
            if let navigator = navigationController {
                navController.addressFor = key!
               
                navigator.pushViewController(navController, animated: false)
            }
        }
        
    }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


