//
//  StoredData.h
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"

@interface StoredData : NSObject

FOUNDATION_EXPORT NSString *const KEY_USER_DATA;

+ (UserData *)userData;
+ (void)commitUserDataWithData:(UserData *)userData;
+ (void)removeUserData;

+ (NSMutableArray *)ticketsQueue;
+ (void)commitTicketsQueueWithList:(NSMutableArray *)ticketsQueueList;
+ (void)removeTicketsQueue;

+ (NSMutableArray *)cardEventsQueue;
+ (void)commitCardEventsQueueWithList:(NSMutableArray *)cardEventsQueueList;
+ (void)removeCardEventsQueue;

@end