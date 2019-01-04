//
//  StoredValueVector.m
//  CDTATicketing
//
//  Created by CooCooTech on 10/20/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "StoredValueVector.h"

NSString *const VECTOR_TYPE_DOLLAR = @"DOLLAR";
NSString *const VECTOR_TYPE_MICRON = @"MICRON";
NSString *const VECTOR_TYPE_NUMERICAL = @"NUMERICAL";
NSString *const VECTOR_TYPE_PERCENTAGE = @"PERCENTAGE";

@implementation StoredValueVector

NSString *const KEY_VECTOR_CURRENCY = @"currency";
NSString *const KEY_VECTOR_MAGNITUDE = @"magnitude";
NSString *const KEY_VECTOR_TYPE = @"type";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.currency = [decoder decodeObjectForKey:KEY_VECTOR_CURRENCY];
        self.magnitude = [decoder decodeFloatForKey:KEY_VECTOR_MAGNITUDE];
        self.type = [decoder decodeObjectForKey:KEY_VECTOR_TYPE];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.currency forKey:KEY_VECTOR_CURRENCY];
    [encoder encodeFloat:self.magnitude forKey:KEY_VECTOR_MAGNITUDE];
    [encoder encodeObject:self.type forKey:KEY_VECTOR_TYPE];
}

@end
