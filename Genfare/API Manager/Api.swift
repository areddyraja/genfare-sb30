//
//  Api.swift
//  Genfare
//
//  Created by vishnu on 23/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

final class Api {
    // MARK: - Private Properties
    //private let manager: ApiManagerProtocol
    
    // MARK: - Designated Initializer
//    init(manager: ApiManagerProtocol = Configuration.manager) {
//        self.manager = manager
//    }
    
    // MARK: - Public Methods
//    func getUserInfo(userId: String, completion: ApiResult<User> -> Void) {
//        manager.apiRequest(.GetUserInfo(userId: userId)).apiResponse { response in
//            switch response.result {
//            case .Success(let json):
//                let user = User(json: json["data"])
//                completion(ApiResult{ return user })
//            case .Failure(let error):
//                completion(ApiResult{ throw error })
//            }
//        }
//    }
//
//    func updateUserInfo(user: User, completion: ApiResult<User> -> Void) {
//        manager.apiRequest(.UpdateUserInfo(userId: user.userId), parameters: user.toParameters()).apiResponse { response in
//            switch response.result {
//            case .Success(let json):
//                let user = User(json: json["data"])
//                completion(ApiResult{ return user })
//            case .Failure(let error):
//                completion(ApiResult{ throw error })
//            }
//        }
//    }
}

