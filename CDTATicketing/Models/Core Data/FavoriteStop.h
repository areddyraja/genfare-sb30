//
//  FavoriteStop.h
//  CDTATicketing
//
//  Created by CooCooTech on 6/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FavoriteStop : NSManagedObject

FOUNDATION_EXPORT NSString *const FAVORITE_STOP_MODEL;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * servicedBy;
@property (nonatomic, retain) NSNumber * stopId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
