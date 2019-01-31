//
//  LaunchScreenViewModel.swift
//  Genfare
//
//  Created by vishnu on 09/01/19.
//  Copyright © 2019 Genfare. All rights reserved.
//

import Foundation
import RxSwift
import NetworkStack
import Alamofire

class LaunchScreenViewModel {

    private let disposeBag = DisposeBag()
    
    // RX
    let isLoading = Variable(false)
    var isSuccess = Variable(false)
    var errorMessage = Variable<String?>(nil)
    
    init () {
        //Initialise the class here
    }
    
    func getAuthToken(completionHandler:@escaping (_ result:Bool,_ error:Any?) -> Void) {
        let assign = GFFirstAuthToken()
        
        isLoading.value = true
        assign.getAuthToken(completionHandler: { [unowned self] (success, error) in
            if success {
                print("got token")
                completionHandler(true,nil)
            }else{
                completionHandler(false,error)
            }
        })
    }
}
