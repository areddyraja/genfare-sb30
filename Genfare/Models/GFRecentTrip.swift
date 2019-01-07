//
//  RecentTrip.swift
//  Genfare
//
//  Created by omniwzse on 26/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation
import MapKit

class GFRecentTrip {
    
    var tripString:String?
    var destination:String?
    var mode:String?
    var tripStartAddress:String?
    var tripEndAddress:String?
    
    //Trip will be saved in string like 40.001654|-83.019736|40.10392484|-83.23553453|BUS,WALK|Ohio State House|Ohio Stadium|Bus 2L, Bus 1
    //start Lan, long, destination lat, long, transit mode, destination name,bus numbers
    init (tString:String) {
        tripString = tString
        let valArray:Array = tString.components(separatedBy: "|")
        mode = valArray.count > 4 ? valArray[4] : ""
        //tripSubString = valArray.count > 7 ? valArray[7] : ""
        tripStartAddress = valArray.count > 5 ? valArray[5] : ""
        tripEndAddress = valArray.count > 6 ? valArray[6] : ""
        destination = valArray.count > 6 ? valArray[6] : ""
    }
    
    var tripSubString:String {
        get {
            var subStr:String = ""
            
            let strComps:Array = (tripString?.components(separatedBy: "|"))!

            if strComps.count > 7 {
                subStr.append(strComps[7])
                subStr.append("from \(startLocation.formattedAddress ?? "")")
            }
            
            return subStr
        }
    }
    
    var destinationShort:String {
        get {
            guard destination != nil else {
                return ""
            }
            
            let strComps:Array = (destination?.components(separatedBy: ","))!
            return strComps.count > 0 ? strComps.first! : ""
        }
    }
    
    var startLocation:GFLocation {
        get {
            
            let strComps:Array = (tripString?.components(separatedBy: "|"))!
            var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            var location:GFLocation = GFLocation(coordinates: coordinate)
            
            if strComps.count > 1 {
                coordinate = CLLocationCoordinate2D(latitude: Double(strComps[0])!, longitude: Double(strComps[1])!)
                location = GFLocation(coordinates: coordinate)
            }
            
            location.formattedAddress = strComps.count > 5 ? strComps[5] : ""
            
            return location
        }
    }
    
    var endLocation:GFLocation {
        get {
            
            let strComps:Array = (tripString?.components(separatedBy: "|"))!
            var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            var location:GFLocation = GFLocation(coordinates: coordinate)
            
            if strComps.count > 3 {
                coordinate = CLLocationCoordinate2D(latitude: Double(strComps[2])!, longitude: Double(strComps[3])!)
                location = GFLocation(coordinates: coordinate)
            }
            
            location.formattedAddress = strComps.count > 6 ? strComps[6] : ""

            return location
        }
    }
    
}
