//
//  GFAccountInfoViewController.swift
//  Genfare
//
//  Created by vishnu on 06/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFAccountInfoViewController: GFBaseViewController {

    @IBOutlet weak var transferBtn: GFMenuButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .gray
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.buttonBGBlue

        // Do any additional setup after loading the view.
    }
    

}

//extension GFAccountInfoViewController : UITableViewDelegate {
//
//}
//
//extension GFAccountInfoViewController : UITableViewDataSource {
//
//}
