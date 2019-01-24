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
    
    func getAuthToken(completionHandler:@escaping (_ result:Any?,_ error:Any?) -> Void) {
        
        let endpoint = GFEndpoint.GetAuthToken(clientId: Utilities.authUserID())

        Alamofire.request(endpoint.url,headers:endpoint.headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    let response = JSON as! [String: Any]
                    if let accesstoken = response["access_token"] {
                        Utilities.saveAccessToken(token: accesstoken as! String)
                    }
                    
                    completionHandler(JSON,nil)
                    //self.loginUser(username: "ttt1@gm.com", password: "12345678")
                    //self.registerUser(username: "ttt1@gm.com", password: "12345678", firstname: "test", lastname: "t")
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completionHandler(nil,error.localizedDescription)
                }
        }
    }
    
    func registerUser(username:String,password:String,firstname:String,lastname:String) {
        let endpoint = GFEndpoint.RegisterUser(email: username, password: password, firstname: firstname, lastname: lastname)

        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: JSONEncoding.default, headers: endpoint.headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func loginUser(username:String,password:String) {
        let endpoint = GFEndpoint.LoginUser(email: username, password: password)
        
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: JSONEncoding.default, headers: endpoint.headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                    self.refreshToken(username: username, password: password)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func refreshToken(username:String,password:String) {
        let endpoint = GFEndpoint.RefreshToken(email: username, password: password)

        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, encoding: URLEncoding.default, headers: endpoint.headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    let response = JSON as! NSDictionary
                    let accesstoken = response.object(forKey: "access_token")
                    print("Token : \(accesstoken)")
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
}
