//
//  PasswordViewModel.swift
//  Genfare
//
//  Created by vishnu on 20/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class PasswordViewModel : ValidationViewModel {
    
    var errorMessage: String = "Please enter a valid Password"
    
    var data: Variable<String> = Variable("")
    var errorValue: Variable<String?> = Variable("")
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data.value, size: (6,15)) else{
            errorValue.value = errorMessage
            return false;
        }
        
        errorValue.value = ""
        return true
    }
    
    func validateLength(text : String, size : (min : Int, max : Int)) -> Bool{
        return (size.min...size.max).contains(text.count)
    }
}
