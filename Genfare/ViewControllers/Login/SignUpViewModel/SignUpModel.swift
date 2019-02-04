//
//  SignUpModel.swift
//  Genfare
//
//  Created by vishnu on 21/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class SignUpModel {
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var password: String = ""
    
    convenience init(firstName:String, lastName:String, email: String, password: String) {
        self.init()
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }
}

