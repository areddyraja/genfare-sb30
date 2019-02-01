//
//  LoginModel.swift
//  Genfare
//
//  Created by vishnu on 08/01/19.
//  Copyright © 2019 Genfare. All rights reserved.
//

import Foundation
import RxSwift

class LoginModel {
    var email: String = ""
    var password: String = ""
    
    convenience init(email: String, password: String) {
        self.init()
        self.email = email
        self.password = password
    }
}

protocol ValidationViewModel {
    
    var errorMessage: String { get }
    
    // Observables
    var data: Variable<String> { get set }
    var errorValue: Variable<String?> { get}
    
    // Validation
    func validateCredentials() -> Bool
}

