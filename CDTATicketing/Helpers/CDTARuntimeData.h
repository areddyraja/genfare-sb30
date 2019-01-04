//
//  CDTARuntimeData.h
//  CDTA
//
//  Created by CooCooTech on 10/15/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Directions.h"

@interface CDTARuntimeData : NSObject

@property (nonatomic) BOOL isAlertShowing;
@property (retain, nonatomic) Directions *tripDirections;
@property (retain, nonatomic) NSArray *nearbyStops;
@property (retain, nonatomic) NSArray *alerts;
@property (retain, nonatomic) NSArray *searchedStops;
@property (retain, nonatomic) NSArray *searchedAddresses;
@property (nonatomic) int fromStopId;
@property (retain, nonatomic) NSString *fromStopName;
@property (nonatomic) double fromStopLatitude;
@property (nonatomic) double fromStopLongitude;
@property (nonatomic) int toStopId;
@property (retain, nonatomic) NSString *toStopName;
@property (nonatomic) double toStopLatitude;
@property (nonatomic) double toStopLongitude;

// TODO: Replace with Core Data
@property (retain, nonatomic) NSArray *payAsYouGoHistory;

+ (id)instance;

@end
