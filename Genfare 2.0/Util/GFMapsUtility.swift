//
//  MapsUtility.swift
//  Genfare
//
//  Created by omniwzse on 21/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation
import MapKit

class MapsUtility {
    
    static func addressFromPlaceMark(placeMark: CLPlacemark) -> String {
        var locationAddress:String = ""
        
        //Location Name
        if let locationName = placeMark.name {
            locationAddress.append(locationName+" ")
        }
        
//        if let street = placeMark.thoroughfare {
//            locationAddress.append(street+" ")
//        }
//        
        if let city = placeMark.subAdministrativeArea {
            locationAddress.append(city+" ")
        }
        
        if let country = placeMark.country {
            locationAddress.append(country+" ")
        }
        
        if let zip = placeMark.postalCode {
            locationAddress.append(zip)
        }
        
        print(locationAddress)
        
        return locationAddress
    }
    
    static func getAddressFromData(data:NSData?) -> String {
        var newaddress = ""
        
        if let data = data {
            let json = try! JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            let status = json["status"] as! String
            if status == "OK" {
                
                if let result = json["results"] as? NSArray   {
                    
                    if result.count > 0 {
                        if let addresss:NSDictionary = result[0] as? NSDictionary {
                            if let address = addresss["address_components"] as? NSArray {
                                var number = ""
                                var street = ""
                                var city = ""
                                var state = ""
                                var zip = ""
                                
                                if(address.count > 1) {
                                    number =  (address.object(at: 0) as! NSDictionary)["short_name"] as! String
                                }
                                if(address.count > 2) {
                                    street = (address.object(at: 1) as! NSDictionary)["short_name"] as! String
                                }
                                if(address.count > 3) {
                                    city = (address.object(at: 2) as! NSDictionary)["short_name"] as! String
                                }
                                if(address.count > 4) {
                                    state = (address.object(at: 4) as! NSDictionary)["short_name"] as! String
                                }
                                if(address.count > 6) {
                                    zip =  (address.object(at: 6) as! NSDictionary)["short_name"] as! String
                                }
                                newaddress = "\(number) \(street), \(city), \(state) \(zip)"
                            }
                        }
                    }
                }
            }
        }
        return newaddress
    }
    
    static func getURLForLatLong(latitude:String,longitude:String) -> URL {
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)")//Here pass your latitude, longitude
        
        return url!
    }
    
    static func getAddressForLatLng(latitude: String, longitude: String) -> String {
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)")//Here pass your latitude, longitude
        print(url!)
        let data = NSData(contentsOf: url! as URL)
        
        return getAddressFromData(data: data)
    }
}
