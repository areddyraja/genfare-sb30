//
//  StoredValueRange.m
//  CDTATicketing
//
//  Created by CooCooTech on 9/29/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "StoredValueRange.h"

@implementation StoredValueRange

NSString *const KEY_MAXIMUM = @"maximum";
NSString *const KEY_MINIMUM = @"minimum";
NSString *const KEY_STEP = @"step";
NSString *const KEY_ORDER = @"order";
NSString *const KEY_NEGATED = @"negated";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.maximum = [decoder decodeFloatForKey:KEY_MAXIMUM];
        self.minimum = [decoder decodeFloatForKey:KEY_MINIMUM];
        self.step = [decoder decodeFloatForKey:KEY_STEP];
        self.order = [decoder decodeObjectForKey:KEY_ORDER];
        self.isNegated = [decoder decodeBoolForKey:KEY_NEGATED];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeFloat:self.maximum forKey:KEY_MAXIMUM];
    [encoder encodeFloat:self.minimum forKey:KEY_MINIMUM];
    [encoder encodeFloat:self.step forKey:KEY_STEP];
    [encoder encodeObject:self.order forKey:KEY_ORDER];
    [encoder encodeBool:self.isNegated forKey:KEY_NEGATED];
}

@end
