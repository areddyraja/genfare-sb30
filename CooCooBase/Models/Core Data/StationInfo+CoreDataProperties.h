//
//  StationInfo+CoreDataProperties.h
//  CooCooBase
//
//  Created by CooCooTech on 1/8/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StationInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface StationInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *displayName;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *stationId;
@property (nullable, nonatomic, retain) NSNumber *transitId;

@end

NS_ASSUME_NONNULL_END
