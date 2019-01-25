//
//  GFEndPoint.swift
//  Genfare
//
//  Created by vishnu on 22/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

enum GFEndpoint {
    case GetAuthToken(clientId: String)
    case RegisterUser(email: String,password:String,firstname:String,lastname:String)
    case LoginUser(email:String,password:String)
    case RefreshToken(email:String,password:String)
    case GetWallets()
    case CheckWalletService()
    
    // MARK: - Public Properties
    var method: Alamofire.HTTPMethod {
        switch self {
        case .GetAuthToken:
            return .get
        case .RegisterUser:
            return .post
        case .LoginUser:
            return .post
        case .RefreshToken:
            return .post
        case .GetWallets:
            return .post
        case .CheckWalletService:
            return .get
        }
    }
    
    var url: String {
        let baseUrl:String = Utilities.authHost()
        switch self {
        case .GetAuthToken(let clientId):
            let auth_url = "/authenticate/oauth/token?grant_type=client_credentials&client_id=\(clientId)"
            return baseUrl+auth_url
        case .RegisterUser:
            let reg_url = "/services/data-api/mobile/users?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+reg_url
        case .LoginUser:
            let loginurl = "/services/data-api/mobile/login?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+loginurl
        case .RefreshToken:
            let url = "/authenticate/oauth/token?grant_type=password"
            return baseUrl+url
        case .GetWallets:
            let url = "/services/data-api/mobile/wallets?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        case .CheckWalletService:
            let url = "/services/data-api/mobile/wallets/for/\(String(describing: KeychainWrapper.standard.string(forKey: Constants.KeyChain.UserName)!))?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        }
    }

    var headers:HTTPHeaders {
        var commonHeaders = ["Accept" : "application/json",
                             "Content-Type":"application/json",
                             "app_version":Utilities.appCurrentVersion(),
                             "app_os":"iOS",
                             "DeviceId":Utilities.deviceId()]
        switch self {
        case .GetAuthToken:
            if let authorizationHeader = Request.authorizationHeader(user: Utilities.authUserID(),password: Utilities.authPassword()) {
                commonHeaders[authorizationHeader.key] = authorizationHeader.value
            }
            return commonHeaders
        case .RefreshToken:
            commonHeaders["Content-Type"] = "application/x-www-form-urlencoded"
            if let authorizationHeader = Request.authorizationHeader(user: Utilities.authUserID(),password: Utilities.authPassword()) {
                commonHeaders[authorizationHeader.key] = authorizationHeader.value
            }
            return commonHeaders
        case .RegisterUser:
            fallthrough
        case .LoginUser:
            commonHeaders["Authorization"] = String(format: "bearer %@", Utilities.accessToken())
            return commonHeaders
        case .GetWallets:
            commonHeaders["Content-Type"] = "application/x-www-form-urlencoded"
            if let authorizationHeader = Request.authorizationHeader(user: Utilities.authUserID(),password: Utilities.authPassword()) {
                commonHeaders[authorizationHeader.key] = authorizationHeader.value
            }
            return commonHeaders
        case .CheckWalletService:
            let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
            commonHeaders["Authorization"] = String(format: "bearer %@", token)
            return commonHeaders
        }
    }
    
    var parameters:[String:String] {
        var parameters:[String:String] = [:]
        switch self {
        case .GetAuthToken:
            return parameters
        case .RegisterUser(let email,let password,let firstname,let lastname):
            parameters = ["emailaddress":email,
             "password":password,
             "firstname":firstname,
             "lastname":lastname]
            return parameters
        case .LoginUser(let username,let password):
            parameters = ["emailaddress":username,
                          "password":password]
            return parameters
        case .RefreshToken(let username,let password):
            parameters = ["username":username,
                          "password":password]
            return parameters
        case .GetWallets():
            parameters = [:]
            return parameters
        case .CheckWalletService():
            parameters = [:]
            return parameters
        }
    }
}
