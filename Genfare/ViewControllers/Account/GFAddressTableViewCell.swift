//
//  GFAddressTableViewCell.swift
//  Genfare
//
//  Created by omniwyse on 12/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFAddressTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
