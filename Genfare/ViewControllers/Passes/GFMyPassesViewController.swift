//
//  GFMyPassesViewController.swift
//  Genfare
//
//  Created by omniwzse on 05/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFMyPassesViewController: GFBaseViewController {

    
    @IBOutlet weak var daysRemainingLabel: UILabel!
    
    @IBOutlet weak var dayPassBtn: UIButton!
    @IBOutlet weak var payGoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.formLabelText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func showDetails(_ sender: UIButton) {
        print(sender)
        if sender == dayPassBtn {
            TripDataManager.selectedPass = "daypass"
        }else{
            TripDataManager.selectedPass = "paypass"
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
