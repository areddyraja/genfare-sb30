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
        return "api.staging.gfcp.io"
    }
    
    class func authHost() -> String {
        return "bct-staging.gfcp.io"
    }

    class func apiURL() -> String {
        return String.init(format: "https://%@", Utilities.apiHost())
    }
    
    class func authURL() -> String {
        return String.init(format: "https://%@", Utilities.authHost())
    }
    
    class func tenantId() -> String {
        return "BCT"
    }

    class func authUserID() -> String {
        return "genfareclient"
    }
    
    class func authPassword() -> String {
        return "GMPyqc1l40XSSus"
    }
    
    class func deviceId() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    class func saveAccessToken(token:String) {
        UserDefaults.standard.set(token, forKey: "common_key_access_token")
        UserDefaults.standard.synchronize()
    }
    
    class func accessToken() -> String {
        return UserDefaults.standard.value(forKey: "common_key_access_token") as! String
    }
}
