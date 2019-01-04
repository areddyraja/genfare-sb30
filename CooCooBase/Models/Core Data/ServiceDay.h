//
//  ServiceDay.h
//  CooCooBase
//
//  Created by CooCooTech on 6/16/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ServiceDay : NSManagedObject

FOUNDATION_EXPORT NSString *const SERVICE_DAY_MODEL;

@property (nonatomic, retain) NSNumber * idNum;
@property (nonatomic, retain) NSNumber * createdDateTime;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * typeSpecific;
@property (nonatomic, retain) NSNumber * serviceSeconds;
@property (nonatomic, retain) NSNumber * serviceSpan;
@property (nonatomic, retain) NSNumber * startSeconds;
@property (nonatomic, retain) NSData * ticketTypes;
@property (nonatomic, retain) NSNumber * updatedDateTime;

@end
