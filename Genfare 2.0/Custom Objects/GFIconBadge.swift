//
//  GFIconBadge.swift
//  Genfare
//
//  Created by omniwzse on 10/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

@IBDesignable
class GFIconBadge: UILabel {

    @IBInspectable var cornerRadius: CGFloat = 3.0
    @IBInspectable var bgColor:CGColor = UIColor.buttonBGBlue.cgColor
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.backgroundColor = bgColor
        sizeToFit()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
