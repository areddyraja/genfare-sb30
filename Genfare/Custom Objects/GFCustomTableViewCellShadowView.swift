//
//  CustomTableViewCellShadowView.swift
//  Genfare
//
//  Created by omniwzse on 23/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

@IBDesignable
class GFCustomTableViewCellShadowView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 3.0
    @IBInspectable var shadowOpacity: Float = 0.5
    @IBInspectable var shadowRadius: CGFloat = 1
    @IBInspectable var shadowColor: CGColor = UIColor.black.cgColor
    @IBInspectable var bgColor:UIColor = .white

    // Set x=5 and y=2 for view inside the cell
    
    override func layoutSubviews() {
        // add shadow on cell
        backgroundColor = .clear // very important
        layer.masksToBounds = false
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowColor = shadowColor
        
        // add corner radius on `contentView`
        backgroundColor = bgColor
        layer.cornerRadius = cornerRadius
        
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
    }

}
