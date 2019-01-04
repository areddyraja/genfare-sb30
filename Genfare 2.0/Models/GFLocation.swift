//
//  GFLocation.swift
//  Genfare
//
//  Created by omniwzse on 30/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation
import MapKit

class GFLocation {
    
    var coordinates:CLLocationCoordinate2D!
    var name:String?
    var formattedAddress:String?
    var boundNorthEast: CLLocationCoordinate2D?
    var boundSouthWest:CLLocationCoordinate2D?
    
    init(coordinates:CLLocationCoordinate2D) {
        self.coordinates = coordinates
    }
    
}
