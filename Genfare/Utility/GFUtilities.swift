//
//  GFUtilities.swift
//  Genfare
//
//  Created by vishnu on 04/01/19.
//  Copyright © 2019 Genfare. All rights reserved.
//

import UIKit

class Utilities {

    class func apiHost() -> String {
        guard let info = Bundle.main.infoDictionary,
            let apiHost = info["api_host"] as? String else {
                fatalError("Cannot get api_host from info.plist")
        }
        return apiHost
    }
    
    class func authHost() -> String {
        guard let info = Bundle.main.infoDictionary,
            let authHost = info["auth_host"] as? String else {
                fatalError("Cannot get auth_host from info.plist")
        }
        return authHost
    }

    class func tenantId() -> String {
        guard let info = Bundle.main.infoDictionary,
            let tenant = info["tenantId"] as? String else {
                fatalError("Cannot get tenant ID from info.plist")
        }
        return tenant
    }

    class func authUserID() -> String {
        guard let info = Bundle.main.infoDictionary,
            let authUser = info["auth_username"] as? String else {
                fatalError("Cannot get auth username from info.plist")
        }
        return authUser
    }
    
    class func authPassword() -> String {
        guard let info = Bundle.main.infoDictionary,
            let authPwd = info["auth_password"] as? String else {
                fatalError("Cannot get auth password from info.plist")
        }
        return authPwd
    }
    
    class func deviceId() -> String {
        return "76B2B88F48B74E7995E9B70BB08F21BA"
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    class func appCurrentVersion() -> String {
        guard let info = Bundle.main.infoDictionary,
            let ver = info["CFBundleShortVersionString"] as? String else {
                fatalError("Cannot get CFBundleShortVersionString from info.plist")
        }
        return ver
    }
    
    class func saveAccessToken(token:String) {
        UserDefaults.standard.set(token, forKey: "common_key_access_token")
        UserDefaults.standard.synchronize()
    }
    
    class func accessToken() -> String {
        return UserDefaults.standard.value(forKey: "common_key_access_token") as! String
    }
    
    class func convertDate(dateStr:String,fromFormat:String, toFormat:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        let date = dateFormatter.date(from: dateStr)
        dateFormatter.dateFormat = toFormat
        return dateFormatter.string(from: date!)
    }
}

