//
//  PurchaseTicketTableViewCell.swift
//  Genfare
//
//  Created by omniwyse on 30/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class PurchaseTicketTableViewCell: UITableViewCell {

    @IBOutlet var RiderName: UILabel!
    @IBOutlet var TicketAmount: UILabel!
    @IBOutlet var RiderTypeDesc: UILabel!
    @IBOutlet var FareZoneCodeDesc: UILabel!
    @IBOutlet var TicketCount: UILabel!
    @IBOutlet var TotalTicketFare: UILabel!
    @IBOutlet var PlusButton: GFMenuButton!
    
    @IBOutlet var MinusButton: GFMenuButton!
    
    func setProductData(product:Product)
    {
        self.RiderName.text = product.productDescription
        self.TotalTicketFare.text = product.ticketTypeDescription
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
