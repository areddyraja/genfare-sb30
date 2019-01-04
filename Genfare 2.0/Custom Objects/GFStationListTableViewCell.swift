//
//  GFStationListTableViewCell.swift
//  Genfare
//
//  Created by omniwzse on 31/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFStationListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var stationAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
