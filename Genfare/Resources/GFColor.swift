//
//  GFColor.swift
//  Genfare
//
//  Created by omniwzse on 10/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    //Dark Blue color for buttons
    static var buttonBGBlue: UIColor {
        return UIColor(red: 34/255, green: 54/255, blue: 104/255, alpha: 1)
    }
    
    //Parot Green color for buttons
    static var buttonBGGreen: UIColor {
        return UIColor(red: 106/255, green: 168/255, blue: 38/255, alpha: 1)
    }
    
    //Sky blue color
    static var mapMakerBlue : UIColor {
        return UIColor(red: 84/255, green: 153/255, blue: 232/255, alpha: 1)
    }
    
    //Dusty gray color, little darker gray
    static var formPlaceHolderText : UIColor {
        return UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
    }
    
    //Alto gray color, light gray color
    static var formLabelText : UIColor {
        return UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1)
    }
    
    //Tundora gray, dark gray color
    static var seconderyText : UIColor {
        return UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
    }
    
    static var topNavBarColor :UIColor {
        let topNavBarColorString:String = Utilities.colorHexString(resourceId:"TopNavBarColor")!
        return UIColor.init(hexString: topNavBarColorString)
    }
    
    static func colorForString(str:String) -> UIColor {
        return UIColor.white
//        let bgColor:String = Utilities.colorHexString(fromId: String.init(format: "%@%@", Utilities.tenantId()?.lowercased() ?? "", str))
//        return UIColor.init(hexString: bgColor)
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    // [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@LoginBGColor",[[Utilities tenantId] lowercaseString]]]]
}

