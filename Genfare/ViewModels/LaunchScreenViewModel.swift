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
    private var accessToken = ""
    
    // RX
    let isLoading = Variable(false)
    var isSuccess = Variable(false)
    var errorMessage = Variable<String?>(nil)
    
    init () {
        self.getAuthToken()
    }
    
    func getAuthToken() {
        
        let auth_url = "/authenticate/oauth/token?grant_type=client_credentials&client_id=genfareclient"
        
        let fullURL = String(format: "%@%@", Utilities.authURL(),auth_url)
        
        var headers:HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: Utilities.authUserID(),password: Utilities.authPassword()) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(fullURL,headers:headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    let response = JSON as! NSDictionary
                    let accesstoken = response.object(forKey: "access_token")
                    
                    print("Token : \(accesstoken)")
                    self.accessToken = accesstoken as! String
                    

                    Utilities.saveAccessToken(token: accesstoken as! String)
                    //self.loginUser(username: "ttt1@gm.com", password: "12345678")
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")

                }
        }
    }
    
    func registerUser(username:String,password:String,firstname:String,lastname:String) {
        
        let registerURL = "/services/data-api/mobile/users?tenant=BCT"
        let fullURL = String(format: "%@%@", Utilities.apiURL(),registerURL)
        
        let headers:HTTPHeaders = ["Authorization":String(format: "bearer %@", self.accessToken),
                                   "Accept":"application/json",
                                   "Content-Type":"application/json",
                                   "app_version":"5.2",
                                   "app_os":"ios",
                                   "DeviceId":"02e1c84df688a47c"]
        
        let parameters:[String:String] = ["emailaddress":username,
                                             "password":password,
                                             "firstname":firstname,
                                             "lastname":lastname]
        
        Alamofire.request(fullURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
        let loginURL = "/services/data-api/mobile/login?tenant=BCT"
        let fullURL = String(format: "%@%@", Utilities.apiURL(),loginURL)
        
        let headers:HTTPHeaders = ["Authorization":String(format: "bearer %@", self.accessToken),
                                   "Accept":"application/json",
                                   "Content-Type":"application/json",
                                   "app_version":"5.2",
                                   "app_os":"ios",
                                   "DeviceId":"02e1c84df688a47c"]
        
        let parameters:[String:String] = ["deviceUUid":"02e1c84df688a47c",
                                          "emailaddress":username,
                                          "password":password]
        
        Alamofire.request(fullURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
        let tokenURL = "/authenticate/oauth/token?grant_type=password"
        let fullURL = String(format: "%@%@", Utilities.authURL(),tokenURL)
        
        let headers:HTTPHeaders = ["Authorization":String(format: "Basic %@", self.accessToken),
                                   "Content-Type":"application/x-www-form-urlencoded",
                                   "DeviceId":"02e1c84df688a47c"]
        
        let parameters:[String:String] = ["emailaddress":username,
                                          "password":password]
        
        
        Alamofire.request(fullURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print(JSON)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
}
