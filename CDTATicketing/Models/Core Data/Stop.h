//
//  Stop.h
//  CDTATicketing
//
//  Created by CooCooTech on 6/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Stop : NSManagedObject

FOUNDATION_EXPORT NSString *const STOP_MODEL;

@property (nonatomic, retain) NSString * arrivalUri;
@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * routeId;
@property (nonatomic, retain) NSString * servicedBy;
@property (nonatomic, retain) NSNumber * stopId;

@end
