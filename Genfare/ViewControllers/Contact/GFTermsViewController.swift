//
//  GFTermsViewController.swift
//  Genfare
//
//  Created by omniwyse on 29/03/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFTermsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Terms of Use"
                navigationController?.setNavigationBarHidden(false, animated: false);
                navigationController?.navigationBar.barTintColor = UIColor.topNavBarColor
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
