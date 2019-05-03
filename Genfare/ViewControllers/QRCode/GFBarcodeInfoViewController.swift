//
//  GFBarcodeInfoViewController.swift
//  Genfare
//
//  Created by vishnu on 11/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFBarcodeInfoViewController: GFBaseViewController {

    var baseClass:UIViewController?
    var ticket:WalletContents!

    @IBOutlet weak var passNameLabel: UILabel!
    @IBOutlet weak var passDetailsLabel: UILabel!
    @IBOutlet weak var passIdLabel: UILabel!
    @IBOutlet weak var passStatusLabel: UILabel!
    @IBOutlet weak var soldOnLabel: UILabel!
    @IBOutlet weak var validFromLabel: UILabel!
    @IBOutlet weak var expiresOnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.topNavBarColor
        view.backgroundColor = .white
        
        // Do any additional setup after loading the view.
        updateDetails()
    }
    
    func updateDetails() {
        passNameLabel.text = ticket.descriptation ?? ""
        passDetailsLabel.text = "\(ticket.type!)\n\(ticket.ticketIdentifier!)\nTotal Fare: $\(ticket.fare!)"
        passIdLabel.text = ticket.ticketIdentifier
        passStatusLabel.text = ticket.status
        
        if let longDate = ticket.purchasedDate as? Double {
            soldOnLabel.text = "\(Utilities.formattedDate(date: longDate/1000))"
        }else{
            soldOnLabel.text = ""
        }
        
        validFromLabel.text = "\(Utilities.formattedDate(date:(Double(ticket.activationDate!.intValue/1000))))"
        
        if let expDate = ticket.expirationDate {
            expiresOnLabel.text = "\(Utilities.convertDate(dateStr: expDate, fromFormat: Constants.Ticket.ExpDateFormat, toFormat: Constants.Ticket.DisplayDateFormat))"
        }else{
            expiresOnLabel.text = ""
        }
    }
}
