//
//  CDTAAppConstants.m
//  CDTA
//
//  Created by CooCooTech on 10/2/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTAAppConstants.h"

@implementation CDTAAppConstants

float const TOOLBAR_HEIGHT = 44.0f;
float const VIEW_PADDING = 4.0f;
float const ALERT_TEXT_SIZE = 12.0f;
float const CELL_HEIGHT_DEFAULT = 44.0f;
float const CELL_HEIGHT_LARGE = 58.0f;
float const SEARCHED_CELL_HEIGHT = 99.0f;
float const CELL_TEXT_SIZE_SMALL = 16.0f;
NSString *const MODE_TRANSIT = @"TRANSIT";
NSString *const MODE_WALKING = @"WALKING";
NSString *const REAL_TIME_ARRIVAL = @"E";
NSString *const ALERT_ALL_ROUTES = @"All Routes";
NSString *const ALERT_NX_ROUTE = @"All Northway Xpress Routes";
int const NX_ROUTE_ID = 540;

// NSUserDefaults
NSString *const KEY_ORIGIN_NAME = @"originName";
NSString *const KEY_ORIGIN_ID = @"originId";
NSString *const KEY_ORIGIN_LATITUDE = @"originLatitude";
NSString *const KEY_ORIGIN_LONGITUDE = @"originLongitude";
NSString *const KEY_DESTINATION_NAME = @"destinationName";
NSString *const KEY_DESTINATION_ID = @"destinationId";
NSString *const KEY_DESTINATION_LATITUDE = @"destinationLatitude";
NSString *const KEY_DESTINATION_LONGITUDE = @"destinationLongitude";

@end
