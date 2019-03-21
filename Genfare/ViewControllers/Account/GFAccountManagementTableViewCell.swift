//
//  GFAccountManagementTableViewCell.swift
//  Genfare
//
//  Created by omniwyse on 20/03/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFAccountManagementTableViewCell: UITableViewCell {

    @IBOutlet var unassignBtn: GFMenuButton!
    @IBOutlet var detailLbl: UILabel!
    @IBOutlet var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
