//
//  GFNetworkReachability.swift
//  Genfare
//
//  Created by vishnu on 08/01/19.
//  Copyright © 2019 Genfare. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    //shared instance
    static let shared = NetworkManager()
    static var Reachability:Bool = true
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    
    func startNetworkReachabilityObserver() {
        
        reachabilityManager?.listener = { status in
            switch status {
                
            case .notReachable:
                print("The network is not reachable")
                NetworkManager.Reachability = false
            case .unknown :
                print("It is unknown whether the network is reachable")
                NetworkManager.Reachability = false

            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
                fallthrough
            case .reachable(.wwan):
                print("The network is reachable over the WWAN connection")
                NetworkManager.Reachability = true

            }
        }
        
        // start listening
        reachabilityManager?.startListening()
    }
}
