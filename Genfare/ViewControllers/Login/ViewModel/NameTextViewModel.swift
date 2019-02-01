//
//  NameTextViewModel.swift
//  Genfare
//
//  Created by vishnu on 21/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class NameTextViewModel : ValidationViewModel {
    
    var errorMessage: String = "Please enter a valid Name"
    
    var data: Variable<String> = Variable("")
    var errorValue: Variable<String?> = Variable("")
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data.value, size: (1,15)) else{
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
