//
//  CardEventFare.m
//  CooCooBase
//
//  Created by CooCooTech on 5/10/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CardEventFare.h"

@implementation CardEventFare

NSString *const KEY_FARE_CODE = @"fareCode";
NSString *const KEY_FARE_REVISION = @"fareRevision";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.code = [decoder decodeObjectForKey:KEY_FARE_CODE];
        self.revision = [decoder decodeObjectForKey:KEY_FARE_REVISION];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.code forKey:KEY_FARE_CODE];
    [encoder encodeObject:self.revision forKey:KEY_FARE_REVISION];
}

@end
