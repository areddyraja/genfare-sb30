//
//  StoredValueDuration.m
//  CDTATicketing
//
//  Created by CooCooTech on 10/20/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "StoredValueDuration.h"

@implementation StoredValueDuration

NSString *const KEY_DURATION = @"duration";
NSString *const KEY_OFFSET = @"offset";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.duration = [decoder decodeIntegerForKey:KEY_DURATION];
        self.offset = [decoder decodeIntForKey:KEY_OFFSET];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.duration forKey:KEY_DURATION];
    [encoder encodeInt:self.offset forKey:KEY_OFFSET];
}

@end
