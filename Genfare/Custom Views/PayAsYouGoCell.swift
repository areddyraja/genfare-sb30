//
//  PayAsYouGoCell.swift
//  Genfare
//
//  Created by vishnu on 01/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class PayAsYouGoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var activeBtn: GFMenuButton!
    @IBOutlet weak var activeRideBtn: GFMenuButton!
    @IBOutlet weak var inactiveBtn: GFMenuButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
