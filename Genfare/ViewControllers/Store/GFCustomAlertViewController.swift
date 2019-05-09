//
//  CustomAlertViewController.swift
//  Genfare
//
//  Created by omniwyse on 07/05/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFCustomAlertViewController: UIViewController {
     var  selectedIndex = -1
    weak var delegate:GFCustomAlertViewControllerDelegate?
    
    
    @IBOutlet var replenishmentBtn: UIButton!
    @IBOutlet var optionViewCreditCard: GFCustomTableViewCellShadowView!
    
    @IBOutlet var creditCardBtn: UIButton!
    @IBOutlet var moneyCardIcon: UIImageView!
    @IBOutlet var fareboxLabel: UILabel!
    @IBOutlet var replenishmentView: GFCustomTableViewCellShadowView!
    @IBOutlet var optionCreditCardLabel: UILabel!
    @IBOutlet var optionCreditCardIcon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
       // GFCustomAlertViewController.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func continueBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.selectedOption(selectedIndex: selectedIndex)
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func selectOption(_ sender: UIButton) {
        if (sender == self.creditCardBtn) {
            selectedIndex = 0;
        }else{
            selectedIndex = 1;
        }
        selectedOptionIndex(Option:selectedIndex)
    }
    func selectedOptionIndex(Option:NSInteger){
        switch(Option) {
        case 0:
            self.optionCreditCardIcon.image = UIImage(named:"credit-card-front-solid-s")
            self.optionCreditCardLabel.textColor = UIColor.white
            self.optionViewCreditCard.backgroundColor = UIColor(hexString:"#223668")
            
            self.moneyCardIcon.image = UIImage(named:"money-check-alt-solid")
            self.fareboxLabel.textColor = UIColor.black
            self.replenishmentView.backgroundColor = UIColor.white
            
            break;
        case 1:
            self.moneyCardIcon.image = UIImage(named:"money-check-alt-solid-s")
            self.fareboxLabel.textColor = UIColor.white
            self.replenishmentView.backgroundColor = UIColor(hexString:"#223668")
            
            self.optionCreditCardIcon.image = UIImage(named:"credit-card-front-solid")
            self.optionCreditCardLabel.textColor = UIColor.black
            self.optionViewCreditCard.backgroundColor = UIColor.white
            
            break;
        default:
            break
        }
    }
    
    
    }
protocol GFCustomAlertViewControllerDelegate: AnyObject {
    func  selectedOption(selectedIndex:NSInteger)
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


