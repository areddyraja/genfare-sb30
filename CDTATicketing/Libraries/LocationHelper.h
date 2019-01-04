//
//  LocationHelper.h
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 4/29/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationHelper : NSObject

+(BOOL)requestWhenInUseAuthorisation:(CLLocationManager*) locationManager;

@end
