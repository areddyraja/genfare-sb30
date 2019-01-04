//
//  LocationHelper.m
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 4/29/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "LocationHelper.h"

@implementation LocationHelper

+ (BOOL)requestWhenInUseAuthorisation:(CLLocationManager*) locationManager
{
    
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        // User has never been asked to decide on location authorization
        if (status == kCLAuthorizationStatusNotDetermined) {
            NSLog(@"Requesting when in use auth");
            
            [locationManager requestWhenInUseAuthorization];
            //[locationManager requestAlwaysAuthorization];
            return true;
        }
        // User has denied location use (either for this app or for all apps
        else if (status == kCLAuthorizationStatusDenied) {
            NSLog(@"Location services denied");
            // Alert the user and send them to the settings to turn on location
            return false;
        }
        
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse){
            
            [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
            [locationManager startUpdatingLocation];
            return true;
        } else
        {
            NSLog(@"Location sevice is not available; status = %d", status);
           
        }
    }
    return false;
}

@end
