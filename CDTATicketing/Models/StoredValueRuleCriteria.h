//
//  StoredValueRuleCriteria.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/21/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoredValueDuration.h"
#import "StoredValueRange.h"
#import "StoredValueVector.h"

@interface StoredValueRuleCriteria : NSObject <NSCoding>

FOUNDATION_EXPORT NSString *const CRITERIA_ATTRIBUTE_ACTIVATIONS;
FOUNDATION_EXPORT NSString *const CRITERIA_ATTRIBUTE_AMOUNT;
FOUNDATION_EXPORT NSString *const CRITERIA_ATTRIBUTE_SUBSTITUTION;

@property (copy, nonatomic) NSString *attribute;
@property (strong, nonatomic) StoredValueRange *entrants;
@property (copy, nonatomic) NSArray *productIds;            // productId is actually productCode; Empty list implies all Stored Value Products receive the benefit
@property (strong, nonatomic) StoredValueDuration *window;
@property (strong, nonatomic) StoredValueVector *amount;

@end
