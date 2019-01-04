//
//  Route.h
//  CDTATicketing
//
//  Created by CooCooTech on 6/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Route : NSManagedObject

FOUNDATION_EXPORT NSString *const ROUTE_MODEL;

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSData * directions;
@property (nonatomic, retain) NSString * directionUri;
@property (nonatomic, retain) NSString * mapImageUrl;
@property (nonatomic, retain) NSString * mapKmlUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * routeDescription;
@property (nonatomic, retain) NSNumber * routeId;
@property (nonatomic, retain) NSString * scheduleUrl;
@property (nonatomic, retain) NSString * textColor;
@property (nonatomic, retain) NSString * uri;

@end
