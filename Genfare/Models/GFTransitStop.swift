//
//  GFTransitStop.swift
//  Genfare
//
//  Created by omniwzse on 10/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation
import MapKit

struct GFTransitStop {
    
    var id = ""
    var code = ""
    var name = ""
    var lat = ""
    var long = ""
    
    var coordinates:CLLocationCoordinate2D?
    
    init(attributes:Dictionary<String,AnyObject>) {
        for (key, value) in attributes {
            //print("Values \(key) - \(value)")
            
            switch key {
            case "id":
                self.id = "\(value)"
                
            case "code":
                self.code = "\(value)"
                
            case "name":
                self.name = "\(value)"
                
            case "lat":
                self.lat = "\(value)"
                
            case "lon":
                self.long = "\(value)"
                
            default:
                break
                
            }
        }
        
        self.coordinates = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (long as NSString).doubleValue)
    }
}
