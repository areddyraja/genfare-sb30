//
//  GFRouteItemsScrollView.swift
//  CDTATicketing
//
//  Created by vishnu on 23/11/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFRouteItemsScrollView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var reloadFlag:Bool = true

    override func layoutSubviews() {
        super.layoutSubviews()
        if reloadFlag {
            self.flashScrollIndicators()
            //reloadFlag = false;
        }
    }
}
