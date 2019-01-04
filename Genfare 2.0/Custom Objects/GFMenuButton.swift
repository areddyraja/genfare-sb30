//
//  GFMenuButton.swift
//  Genfare
//
//  Created by omniwzse on 12/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

@IBDesignable
class GFMenuButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 3.0
    @IBInspectable var bgColor:CGColor = UIColor.buttonBGBlue.cgColor
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
