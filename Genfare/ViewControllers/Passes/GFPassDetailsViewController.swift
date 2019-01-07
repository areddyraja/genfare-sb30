//
//  GFPassDetailsViewController.swift
//  Genfare
//
//  Created by omniwzse on 05/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFPassDetailsViewController: GFBaseViewController {

    @IBOutlet weak var passTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.formLabelText
        updateUIForPass()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func updateUIForPass() {
        for i in 1...6 {
            let bview = view.viewWithTag(i)
            bview?.isHidden = true
        }
        
        switch TripDataManager.selectedPassNum {
        case 101:
            let bview = view.viewWithTag(1)
            bview?.isHidden = false
            passTitle.text = "Pay As You Go"
        case 102:
            let bview = view.viewWithTag(2)
            bview?.isHidden = false
            passTitle.text = "31-Day Pass(Discount)"
        case 103:
            let bview = view.viewWithTag(3)
            bview?.isHidden = false
            passTitle.text = "31-Day Pass(Rush Hour)"
        case 104:
            let bview = view.viewWithTag(4)
            bview?.isHidden = false
            passTitle.text = "31-Day Pass"
        case 105:
            let bview = view.viewWithTag(5)
            bview?.isHidden = false
            passTitle.text = "7-Day Pass"
        case 106:
            let bview = view.viewWithTag(6)
            bview?.isHidden = false
            passTitle.text = "Day Pass"
        default:
            print("None selected")
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
