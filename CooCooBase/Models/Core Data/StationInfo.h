//
//  StationInfo.h
//  CooCooBase
//
//  Created by CooCooTech on 1/8/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface StationInfo : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

FOUNDATION_EXPORT NSString *const STATION_INFO_MODEL;

@end

NS_ASSUME_NONNULL_END

#import "StationInfo+CoreDataProperties.h"
