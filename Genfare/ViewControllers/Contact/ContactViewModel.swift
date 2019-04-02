//
//  ContactViewModel.swift
//  Genfare
//
//  Created by omniwyse on 02/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class ContactViewModel {
    
    let disposebag = DisposeBag()
    
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    
    func formErrorString() -> String {
        return ""
    }
    
    
}
