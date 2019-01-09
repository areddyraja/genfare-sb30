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
    @IBInspectable var bgColor = UIColor.colorFromHexString(hexString:  GFUtilities.sharedResource().colorHexString(fromId: GFUtilities.sharedResource().bgcolor()), withAlpha: 1.0)      //UIColor.buttonBGBlue.cgColor
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = bgColor.cgColor
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
