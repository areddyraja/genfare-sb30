//
//  StoredValueCurrency.m
//  CDTATicketing
//
//  Created by CooCooTech on 10/20/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "StoredValueCurrency.h"

@implementation StoredValueCurrency

NSString *const KEY_CURRENCY_ID = @"id";
NSString *const KEY_CURRENCY_SYMBOL = @"symbol";
NSString *const KEY_CURRENCY_IS_PREFIX = @"isPrefix";
NSString *const KEY_CURRENCY_PERCENTAGE = @"percentage";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.currencyId = [decoder decodeIntForKey:KEY_CURRENCY_ID];
        self.symbol = [decoder decodeObjectForKey:KEY_CURRENCY_SYMBOL];
        self.isPrefix = [decoder decodeBoolForKey:KEY_CURRENCY_IS_PREFIX];
        self.modifierPercentage = [decoder decodeFloatForKey:KEY_CURRENCY_PERCENTAGE];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.currencyId forKey:KEY_CURRENCY_ID];
    [encoder encodeObject:self.symbol forKey:KEY_CURRENCY_SYMBOL];
    [encoder encodeBool:self.isPrefix forKey:KEY_CURRENCY_IS_PREFIX];
    [encoder encodeFloat:self.modifierPercentage forKey:KEY_CURRENCY_PERCENTAGE];
}

@end
