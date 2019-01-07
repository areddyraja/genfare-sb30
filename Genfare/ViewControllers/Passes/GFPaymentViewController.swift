//
//  GFPaymentViewController.swift
//  Genfare
//
//  Created by omniwzse on 05/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFPaymentViewController: GFBaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.white
        updateUIForPrice()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func verifyPayment(_ sender: UIButton) {
        popupAlert(title: "Thank You", message: "Payment Successful..!", actionTitles: ["Go to My Passes"], actions: [{ Void in
            self.goToRoot(sender)
            }])
    }
    
    func updateUIForPrice() {
        switch TripDataManager.selectedPassNum {
        case 101:
            totalLabel.text = "Total: $7.00"
        case 102:
            totalLabel.text = "Total: $31.00"
        case 103:
            totalLabel.text = "Total: $85.50"
        case 104:
            totalLabel.text = "Total: $64.50"
        case 105:
            totalLabel.text = "Total: $24.50"
        case 106:
            totalLabel.text = "Total: $4.50"
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
