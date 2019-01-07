//
//  GFTextFieldBackGround.swift
//  Genfare
//
//  Created by omniwzse on 23/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

@IBDesignable
class GFTextFieldBackGround: UIView {

    @IBInspectable var cornerRadius: CGFloat = 3.0
    @IBInspectable var shadowOpacity: Float = 0.5
    @IBInspectable var shadowRadius: CGFloat = 1
    @IBInspectable var shadowColor: CGColor = UIColor.black.cgColor
    @IBInspectable var bgColor:UIColor = .white
    @IBInspectable var selected:Bool = false
    
    override func layoutSubviews() {
        self.layer.cornerRadius = cornerRadius
        
        layer.masksToBounds = false
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowColor = shadowColor
        
        if selected {
            //backgroundColor = 
        }

    }
}
