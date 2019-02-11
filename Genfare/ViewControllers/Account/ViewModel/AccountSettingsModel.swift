//
//  AccountSettingsModel.swift
//  Genfare
//
//  Created by omniwyse on 08/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift


class AccountSettingsModel{
    var email: String = ""
    var password: String = ""
    
    convenience init(email: String, password: String) {
        self.init()
        self.email = email
        self.password = password
    }
}


