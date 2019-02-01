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
    case CheckWalletService()
    case CreateWallet(wallet:String)
    case GetEncryptionKeys()
    case GetConfigApi()
    case GetAccountBalance()
    case WalletContents(walledId:NSNumber)
    case AssignWallet(walletId:NSNumber)
    case ReleaseWallet(walletId:NSNumber)
    case FetchProducts(walletId:NSNumber)
    
    // MARK: - Public Properties
    static var commonHeaders:HTTPHeaders {
        let commonHeaders = ["Accept" : "application/json",
                             "Content-Type":"application/json",
                             "app_version":Utilities.appCurrentVersion(),
                             "app_os":"iOS",
                             "DeviceId":Utilities.deviceId()]
        
        return commonHeaders
    }

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
        case .CheckWalletService:
            return .get
        case .CreateWallet:
            return .post
        case .GetEncryptionKeys:
            return .get
        case .GetConfigApi:
            return .get
        case .GetAccountBalance:
            return .get
        case .WalletContents:
            return .get
        case .AssignWallet:
            return .post
        case .ReleaseWallet:
            return .post
        case .FetchProducts:
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
        case .CheckWalletService:
            let url = "/services/data-api/mobile/wallets/for/\(String(describing: KeychainWrapper.standard.string(forKey: Constants.KeyChain.UserName)!))?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        case .CreateWallet:
            let url = "/services/data-api/mobile/wallets/?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        case .GetEncryptionKeys:
            let url = "/services/data-api/mobile/encryptionkey?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        case .GetConfigApi:
            let url  = "/services/data-api/mobile/config?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        case .GetAccountBalance:
            let  url = "/services/data-api/mobile/account/balance?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        case .WalletContents(let walletId):
            let  url = "/services/data-api/mobile/wallets/\(walletId)/contents?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        case .AssignWallet(let walletId):
            let  url = "/services/data-api/mobile/wallets/\(walletId)/assignto/\(Utilities.deviceId())?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        case .ReleaseWallet(let walletId):
            let  url = "/services/data-api/mobile/wallets/\(walletId)/release?tenant=\(Utilities.tenantId())"
            return Utilities.apiHost()+url
        case .FetchProducts(let walletId):
            let  url = "/services/data-api/mobile/products?tenant=\(Utilities.tenantId())&walletId=\(walletId)"
            return Utilities.apiHost()+url

        }
    }
}
