//
//  TripHistory.h
//  CDTATicketing
//
//  Created by CooCooTech on 6/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TripHistory : NSManagedObject

FOUNDATION_EXPORT NSString *const TRIP_HISTORY_MODEL;

@property (nonatomic, retain) NSNumber * destinationLatitude;
@property (nonatomic, retain) NSNumber * destinationLongitude;
@property (nonatomic, retain) NSString * destinationName;
@property (nonatomic, retain) NSNumber * destinationStopId;
@property (nonatomic, retain) NSNumber * originLatitude;
@property (nonatomic, retain) NSNumber * originLongitude;
@property (nonatomic, retain) NSString * originName;
@property (nonatomic, retain) NSNumber * originStopId;

@end
