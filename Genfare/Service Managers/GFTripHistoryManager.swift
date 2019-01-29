//
//  GFTripHistoryManager.swift
//  Genfare
//
//  Created by omniwzse on 26/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation

class TripHistoryManager {
    
    static func saveTripToRecents(route:GFRoute) -> Bool {
        let tripToBeSaved = route.recentTripString()
        let defauts = UserDefaults.standard
        if let recents = defauts.stringArray(forKey: Constants.LocalStorage.RecentTrips) {
            for str in recents {
                if str == tripToBeSaved {
                    //Trip already exists
                    return false
                }
            }
            saveTrip(list: recents, item: tripToBeSaved)
        }else {
            saveTrip(list: [], item: tripToBeSaved)
        }
        
        return true
    }
    
    static func saveTrip(list:Array<String>,item:String) {
        let defaults = UserDefaults.standard
        var newArray = Array(list)
        newArray.append(item)
        defaults.set(newArray, forKey: Constants.LocalStorage.RecentTrips)
        defaults.synchronize()
    }
    
    static func getRecentTrips() -> Array<GFRecentTrip> {

        let defaults = UserDefaults.standard
        let strArray = defaults.array(forKey: Constants.LocalStorage.RecentTrips)
        var tripsArray:Array<GFRecentTrip> = []

        guard strArray != nil else {
            return tripsArray
        }

        for str in strArray! {
            let trip:GFRecentTrip = GFRecentTrip(tString: str as! String)
            tripsArray.append(trip)
        }
        
        return tripsArray
    }
}

