//
//  GFRouteLeg.swift
//  Genfare
//
//  Created by omniwzse on 10/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation
import MapKit

struct GFRouteLeg {
    
    var mode:String!
    var name:String?
    var formattedAddress:String?
    var coordinates:CLLocationCoordinate2D!
    var startTime:NSNumber?
    var endTime:NSNumber?
    var distance:Float?
    var duration:Float?
    var routeNumber:String?
    var fare:Float?
    var agencyID:String?
    var arrivalTime:String?
    var depTime:String?
    var stopsList:Array<GFStation>?
    var points:String?
    var pointsLength:Int?
    var timeZoneOffset:NSNumber?
    
    init(mode:String) {
        self.mode = mode
    }
    
    func polyPoints() -> Array<CLLocation> {
        return EncodeUtil.decodePolyLine(points) as! Array<CLLocation>
    }
    
    func remainingTime() -> Double {
        //Get the current date and time in seconds
        let currentDate = Date().timeIntervalSince1970 as Double
        
        //Get agency time zone in seconds. Because the actual value is in milliseconds divide it by 1000 to convert it to seconds
        let timeZoneOffsetSec = Double(truncating: timeZoneOffset!)/1000
        
        //Get the device local time zone offset
        let currentTimeZoneOffset = Double(TimeZone.current.secondsFromGMT())

        //StartTime is also in milliseconds so devide it by 100
        //We get startTime in agency local time, and currentTime is in device local time
        //So, subtract it with the time differences to get the actual time difference between startTime and currentTime
        let utcTime = (Double(truncating: startTime!)/1000 - currentDate) - (currentTimeZoneOffset - timeZoneOffsetSec)

        //The final return value is in seconds
        return utcTime
    }
    
    func arrivalTimeString () -> String {
        let date = Date(timeIntervalSince1970: Double(truncating: startTime!)/1000 )
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "ET") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"

        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
}
