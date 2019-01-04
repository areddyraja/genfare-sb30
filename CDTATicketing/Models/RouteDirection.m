//
//  RouteDirection.m
//  CDTA
//
//  Created by CooCooTech on 11/13/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "RouteDirection.h"

@implementation RouteDirection

NSString *const KEY_DIRECTION_ID = @"directionId";
NSString *const KEY_ROUTE_DIRECTION_NAME = @"name";
NSString *const KEY_SCHEDULE_URI = @"scheduleUri";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.directionId = (int)[decoder decodeIntegerForKey:KEY_DIRECTION_ID];
        self.name = [decoder decodeObjectForKey:KEY_ROUTE_DIRECTION_NAME];
        self.scheduleUri = [decoder decodeObjectForKey:KEY_SCHEDULE_URI];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.directionId forKey:KEY_DIRECTION_ID];
    [encoder encodeObject:self.name forKey:KEY_ROUTE_DIRECTION_NAME];
    [encoder encodeObject:self.scheduleUri forKey:KEY_SCHEDULE_URI];
}

@end
