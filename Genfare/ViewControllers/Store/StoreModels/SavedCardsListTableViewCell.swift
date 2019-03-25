//
//  SavedCardsListTableViewCell.swift
//  Genfare
//
//  Created by omniwyse on 18/03/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class SavedCardsListTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var canrdNumberLabel: UILabel!
    @IBOutlet weak var Cardimage: UIImageView!
    @IBOutlet weak var CardBgview: UIView!
        override func awakeFromNib() {
        super.awakeFromNib()
             deleteButton.setImage(UIImage(named: "card_delete_image"), for: .normal)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
