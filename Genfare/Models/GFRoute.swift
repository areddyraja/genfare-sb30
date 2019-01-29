//
//  GFRoute.swift
//  Genfare
//
//  Created by omniwzse on 10/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation

struct GFRoute {
    
    var startTime:NSNumber?
    var endTime:NSNumber?
    var walkDistance:Float?
    var duration:Float?
    var fare:Float?
    var transfers:Int = 0
    var startingLocation:GFLocation?
    var destination:GFLocation?
    var tripMode:String?

    var legsList:Array<GFRouteLeg>?
    
    init (list:Array<GFRouteLeg>) {
        legsList = list
    }
    
    func departsIn() -> String {
        var etaSeconds:Double
        if legsList![0].mode! == Constants.TransitMode.Walk {
            etaSeconds = legsList![1].remainingTime()
        }else{
            etaSeconds = legsList![0].remainingTime()
        }
        
        return "\(Int(etaSeconds/60))"
    }
    
    func startBusNumber() -> String {
        var busNo:String = ""
        if legsList![0].mode! == Constants.TransitMode.Walk {
            busNo = "\(String(describing: legsList![1].routeNumber!))" 
        }else{
            busNo = "\(String(describing: legsList![0].routeNumber!))"
        }
        return busNo
    }
    
    func arrivalTimeString() -> String{
        guard (legsList?.count)! > 1 else {
            return ""
        }
        
        var arrTime:String = ""
        if legsList![0].mode! == Constants.TransitMode.Walk {
            arrTime = "\(String(describing: legsList![1].arrivalTimeString()))"
        }else{
            arrTime = "\(String(describing: legsList![0].arrivalTimeString()))"
        }
        return arrTime
    }
    
}

extension GFRoute {
    
    func recentTripString() -> String {
        //Trip will be saved in string like 40.001654|-83.019736|40.10392484|-83.23553453|BUS,WALK|Ohio State House|Bus 2L, Bus 1
        var busString:String = ""
        
        for leg:GFRouteLeg in legsList! {
            if leg.mode != Constants.TransitMode.Walk {
                if leg.mode == Constants.TransitMode.Bus {
                    busString.append("Bus \(leg.routeNumber ?? " "), ")
                }
            }
        }
        
        let resultStr:String = String("\(startingLocation?.coordinates.latitude ?? 0)|\(startingLocation?.coordinates.longitude ?? 0)|\(destination?.coordinates.latitude ?? 0)|\(destination?.coordinates.longitude ?? 0)|\(tripMode ?? " ")|\(startingLocation?.formattedAddress ?? " ")|\(destination?.formattedAddress ?? " ")|\(busString)")
        
        return resultStr
    }
}
