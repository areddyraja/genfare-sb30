//
//  TripDataManager.swift
//  Genfare
//
//  Created by omniwzse on 20/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation
import SwiftyJSON

class TripDataManager {
    
    static var serviceStatusOn: Bool = false
    static var startingPoint:GFLocation?
    static var endPoint:GFLocation?
    static var startingPointString:String?
    static var endPointString:String?
    static var stationsList:Array<GFStation>?
    static var routesList:Array<GFRoute>?
    static var selectedRoute:GFRoute?
    static var tripMode:String = Constants.TransitMode.WalkBus
    
    static var selectedPass:String?
    static var selectedPassNum:Int?
    
    static func initService (completionHandler:@escaping (_ success:Bool)->Void) {
        //TODO - Evaluate this method and remove if not required
        //        let initEndPoint: String = "https://otp.genfaremobile.com/otp"
        //
        //        Alamofire.request(initEndPoint).responseJSON { response in
        //
        //            //Check for errors
        //            guard response.result.error == nil else {
        //                //Got an error in getting the data, need to handle it
        //                print("Error connecting to service")
        //                print(response.result.error.debugDescription)
        //                completionHandler(false)
        //                return
        //            }
        //
        //            //Make sure we got some JSON since that's what we expect
        //            guard (response.result.value as? [String: Any]) != nil else {
        //                print("Din't get object from JSON ")
        //                if let error = response.result.error {
        //                    print("Error: \(error)")
        //                }
        //                completionHandler(false)
        //                return
        //            }
        //
        //            serviceStatusOn = true
        //            completionHandler(true)
        //        }
    }
    
    static func resetTrip() {
        startingPoint = nil
        endPoint = nil
    }
    
    static func getRegionBoundaries () -> Array<Any> {
        //TODO - Evaluate this method and remove if not required
        //        let regionEndPoint: String = "https://otp.genfaremobile.com/otp/routers/default"
        //
        //        Alamofire.request(regionEndPoint).responseJSON { response in
        //
        //
        //        }
        //
        return []
    }
    
    static func getRoutsForLocations(completionHandler:@escaping (_ success:Bool)->Void) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let resultDate = formatter.string(from: date)
        let resultTime = String("\(Calendar.current.component(.hour, from: Date())):\(Calendar.current.component(.minute, from: Date()))")
        
        var fromPlace:String = ""
        var toPlace:String = ""
        
        if (TripDataManager.startingPoint?.coordinates.latitude) != nil {
            fromPlace.append(String(format:"%.16f",(TripDataManager.startingPoint?.coordinates.latitude)!))
        }
        
        if (TripDataManager.startingPoint?.coordinates.longitude) != nil {
            fromPlace.append(String(format:",%.16f",(TripDataManager.startingPoint?.coordinates.longitude)!))
        }
        
        if (TripDataManager.endPoint?.coordinates.latitude) != nil {
            toPlace.append(String(format:"%.16f",(TripDataManager.endPoint?.coordinates.latitude)!))
        }
        
        if (TripDataManager.endPoint?.coordinates.longitude) != nil {
            toPlace.append(String(format:",%.16f",(TripDataManager.endPoint?.coordinates.longitude)!))
        }
        
        routesList = []
        
        var urlRequest:URLRequest = getURLForTripScheddule(params: ["mode":tripMode,
                                                                    "date":resultDate,
                                                                    "arriveBy":"false",
                                                                    "wheelchair":"false",
                                                                    "optimize":"QUICK",
                                                                    "showIntermediateStops":"true",
                                                                    "fromPlace": fromPlace,
                                                                    "toPlace": toPlace,
                                                                    "maxWalkDistance": "1600",
                                                                    "time": resultTime])
        
        urlRequest.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        print(urlRequest)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                parseRouts(data: data!)
                if routesList?.count == 0 {
                    completionHandler(false)
                }else {
                    completionHandler(true)
                }
            }else {
                completionHandler(false)
            }
        }
        
        task.resume()
    }
    
    static func parseRouts(data:Data) {
        
        //TODO - Important Need to handle JSON Parsing
        routesList = []
        let json = JSON(data)
        
        if json["plan"]["itineraries"].count > 0 {
            
            for i in 0...(json["plan"]["itineraries"].count-1) {
                var route:GFRoute
                var legList:Array<GFRouteLeg> = []
                
                if json["plan"]["itineraries"][i]["legs"].count > 0 {
                    var leg:GFRouteLeg
                    for j in 0...(json["plan"]["itineraries"][i]["legs"].count-1) {
                        if let mode = json["plan"]["itineraries"][i]["legs"][j]["mode"].string {
                            leg = GFRouteLeg(mode: mode)
                            leg.startTime = json["plan"]["itineraries"][i]["legs"][j]["startTime"].number
                            leg.endTime = json["plan"]["itineraries"][i]["legs"][j]["endTime"].number
                            leg.timeZoneOffset = json["plan"]["itineraries"][i]["legs"][j]["agencyTimeZoneOffset"].number
                            leg.distance = json["plan"]["itineraries"][i]["legs"][j]["distance"].float
                            leg.duration = json["plan"]["itineraries"][i]["legs"][j]["duration"].float
                            leg.routeNumber = json["plan"]["itineraries"][i]["legs"][j]["route"].string
                            leg.agencyID = json["plan"]["itineraries"][i]["legs"][j]["agencyId"].string
                            leg.points = json["plan"]["itineraries"][i]["legs"][j]["legGeometry"]["points"].string
                            //TODO - inserting a wrong value intensionally, need to change it later
                            leg.arrivalTime = json["plan"]["itineraries"][i]["legs"][j]["arrival"].string
                            //TODO - Add all the pending properties
                            legList.append(leg)
                            print(leg.remainingTime())
                        }
                    }
                    
                    route = GFRoute(list: legList)
                    route.startTime = json["plan"]["itineraries"][i]["startTime"].number ?? 0.0
                    route.endTime = json["plan"]["itineraries"][i]["endTime"].number ?? 0.0
                    route.duration = json["plan"]["itineraries"][i]["duration"].float ?? 0.0
                    route.fare = json["plan"]["itineraries"][i]["fare"]["fare"]["regular"]["cents"].float ?? 0.0
                    route.transfers = json["plan"]["itineraries"][i]["transfers"].int ?? 0
                    route.walkDistance = json["plan"]["itineraries"][i]["walkDistance"].float ?? 0.0
                    route.startingLocation = startingPoint
                    route.destination = endPoint
                    route.tripMode = tripMode
                    routesList?.append(route)
                }
            }
        }
        
        //print(json)
    }
    
    static func getURLForTripScheddule(params:[String:String]) -> URLRequest {
        
        let urlComp = NSURLComponents(string: "https://otp.genfaremobile.com/otp/routers/default/plan")!
        
        var items = [URLQueryItem]()
        
        for (key,value) in params {
            items.append(URLQueryItem(name: key, value: value))
        }
        
        items = items.filter{!$0.name.isEmpty}
        
        if !items.isEmpty {
            urlComp.queryItems = items
        }
        
        let urlRequest = URLRequest(url: urlComp.url!)
        
        return urlRequest
    }
    
    static func getStopsInBetween() {
        //TODO - Evaluate this method and remove if not required
        //        let stopsEndPoint:String = "https://otp.genfaremobile.com/otp/routers/default/index/stops"
        //
        //        Alamofire.request(stopsEndPoint, method:.get).responseSwiftyJSON { dataResponse in
        //
        //            guard dataResponse.error == nil else {
        //                //Got an error in getting the data, need to handle it
        //                print("Error connecting to service")
        //                return
        //            }
        //
        //            print(dataResponse.value?.count as Any)
        //
        //            guard (dataResponse.value?.count)! > 0 else {
        //                stationsList = []
        //                return
        //            }
        //
        //            stationsList = []
        //
        //            for object in dataResponse.value! {
        //                //print(object)
        //                //stationsList?.append(GFStation(attributes: object.1.dictionary))
        //                appendStation(station: object.1.dictionary as AnyObject)
        //            }
        //        }
    }
    
    static func getRecentTripString(route:GFRoute) -> String {
        //Trip will be saved in string like 40.001654|-83.019736|40.10392484|-83.23553453|BUS,WALK|Ohio State House|Bus 2L, Bus 1
        var busString:String = ""
        
        for leg:GFRouteLeg in route.legsList! {
            if leg.mode != Constants.TransitMode.Walk {
                if leg.mode == Constants.TransitMode.Bus {
                    busString.append("Bus \(String(describing: leg.routeNumber)), ")
                }
            }
        }
        
        let resultStr:String = String("\(String(describing: route.startingLocation?.coordinates.latitude))|\(String(describing: route.startingLocation?.coordinates.longitude))|\(String(describing: route.destination?.coordinates.latitude))|\(String(describing: route.destination?.coordinates.longitude))|\(String(describing: route.tripMode))|\(String(describing: route.destination?.formattedAddress))|\(busString)")
        
        return resultStr
    }
    
    static func appendStation(station:AnyObject) {
        stationsList?.append(GFStation(attributes: station as! Dictionary<String, AnyObject>))
    }
    
}
