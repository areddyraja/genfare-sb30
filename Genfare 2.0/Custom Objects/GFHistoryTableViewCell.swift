//
//  GFHistoryTableViewCell.swift
//  Genfare
//
//  Created by omniwzse on 28/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descText: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
