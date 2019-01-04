//
//  StoredValueRuleCriteria.m
//  CDTATicketing
//
//  Created by CooCooTech on 10/21/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "StoredValueRuleCriteria.h"

NSString *const CRITERIA_ATTRIBUTE_ACTIVATIONS = @"ACTIVATIONS";
NSString *const CRITERIA_ATTRIBUTE_AMOUNT = @"AMOUNT";
NSString *const CRITERIA_ATTRIBUTE_SUBSTITUTION = @"SUBSTITUTION";

@implementation StoredValueRuleCriteria

NSString *const KEY_CRITERIA_ATTRIBUTE = @"attribute";
NSString *const KEY_CRITERIA_ENTRANTS = @"entrants";
NSString *const KEY_CRITERIA_PRODUCTS = @"products";
NSString *const KEY_CRITERIA_WINDOW = @"window";
NSString *const KEY_CRITERIA_AMOUNT = @"amount";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.attribute = [decoder decodeObjectForKey:KEY_CRITERIA_ATTRIBUTE];
        self.entrants = [decoder decodeObjectForKey:KEY_CRITERIA_ENTRANTS];
        self.productIds = [decoder decodeObjectForKey:KEY_CRITERIA_PRODUCTS];
        self.window = [decoder decodeObjectForKey:KEY_CRITERIA_WINDOW];
        self.amount = [decoder decodeObjectForKey:KEY_CRITERIA_AMOUNT];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.attribute forKey:KEY_CRITERIA_ATTRIBUTE];
    [encoder encodeObject:self.entrants forKey:KEY_CRITERIA_ENTRANTS];
    [encoder encodeObject:self.productIds forKey:KEY_CRITERIA_PRODUCTS];
    [encoder encodeObject:self.window forKey:KEY_CRITERIA_WINDOW];
    [encoder encodeObject:self.amount forKey:KEY_CRITERIA_AMOUNT];
}

@end
