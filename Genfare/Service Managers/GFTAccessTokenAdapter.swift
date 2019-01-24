//
//  GFAccessTokenAdapter.swift
//  Genfare
//
//  Created by vishnu on 09/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import Alamofire

final class GFTAccessTokenAdapter: RequestAdapter {
    typealias GFT = String
    private let accessToken: GFT
    
    init(accessToken: GFT) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(Utilities.apiHost()) {
            /// Set the Authorization header value using the access token.
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}
