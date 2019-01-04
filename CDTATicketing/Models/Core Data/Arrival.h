//
//  Arrival.h
//  CDTATicketing
//
//  Created by CooCooTech on 6/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Arrival : NSManagedObject

FOUNDATION_EXPORT NSString *const ARRIVAL_MODEL;

@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSString * minutes;
@property (nonatomic, retain) NSNumber * routeId;
@property (nonatomic, retain) NSString * routeName;
@property (nonatomic, retain) NSNumber * stopId;
@property (nonatomic, retain) NSString * stopName;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * uri;

@end
