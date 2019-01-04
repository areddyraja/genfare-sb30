//
//  GFNavLogoImageView.swift
//  CDTATicketing
//
//  Created by omniwzse on 13/11/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFNavLogoImageView: UIImageView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.image = UIImage.init(named: "bct-logo-blue")
    }
    
}
