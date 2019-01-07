//
//  GFActivatePassViewController.swift
//  Genfare
//
//  Created by omniwzse on 05/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFActivatePassViewController: GFBaseViewController {

    @IBOutlet weak var remainValueView: GFTextFieldBackGround!
    @IBOutlet weak var remainDaysView: GFTextFieldBackGround!
    
    @IBOutlet weak var daysRemainLabel: UILabel!
    @IBOutlet weak var passTitleLabel: UILabel!
    @IBOutlet weak var expiresLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.formLabelText
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        remainValueView.isHidden = true
        remainDaysView.isHidden = true
        
        if TripDataManager.selectedPass == "daypass" {
            remainDaysView.isHidden = false
            passTitleLabel.text = "31-Day Pass"
            expiresLabel.isHidden = false
        }else{
            remainValueView.isHidden = false
            passTitleLabel.text = "Pay As You Go"
            expiresLabel.isHidden = true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender)
    }

}
