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
    
    func openURL() {
        if let url = URL(string: "http://www.cota.com"), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func updateUI(){
        vistTheWebsiteProperty.backgroundColor = UIColor(hexString:"#459EAC")
        callNumberProperty.backgroundColor = UIColor(hexString:"#459EAC")
        commentsProperty.backgroundColor = UIColor(hexString:"#459EAC")
    }
    
    func eMail(){
        if let url = URL(string:"mailto:Requests@cota.com"), !url.absoluteString.isEmpty{
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
