//
//  GFUtilities.swift
//  Genfare
//
//  Created by vishnu on 04/01/19.
//  Copyright © 2019 Genfare. All rights reserved.
//

import UIKit

class GFUtilities: NSObject {
 static var gfutilities = GFUtilities()
    class func sharedResource()-> GFUtilities{
        return self.gfutilities
    }
    func tenantId() -> String {
        var tenantid = Bundle.main.object(forInfoDictionaryKey: "tenantId") as! String
        return tenantid
    }
    func bgcolor() -> String{
        let  string1 = "buttonBG"
        var string2 =  GFUtilities.sharedResource().tenantId().lowercased()
        let colorString = string2+string1
        
        return colorString
        
    }
    func colorHexString(fromId resourceId: String?) -> String? {
        var colorHexString = ""
        var colorsPlistPath = Bundle.main.path(forResource: "Colors", ofType: "plist")
        if (colorsPlistPath?.count ?? 0) > 0 {
            let colorsDictionary = NSDictionary(contentsOfFile: colorsPlistPath ?? "")
            colorHexString = colorsDictionary?[resourceId] as? String ?? ""
        }
        if !(colorHexString.count > 0) {
            colorsPlistPath = Bundle.main.path(forResource: "Colors", ofType: "plist")
            let colorsDictionary = NSDictionary(contentsOfFile: colorsPlistPath ?? "")
            colorHexString = colorsDictionary?[resourceId] as? String ?? ""
        }
        return colorHexString
    }
}
