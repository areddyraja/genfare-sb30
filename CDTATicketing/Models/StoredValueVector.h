//
//  StoredValueVector.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/20/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoredValueCurrency.h"

@interface StoredValueVector : NSObject <NSCoding>

FOUNDATION_EXPORT NSString *const VECTOR_TYPE_DOLLAR;
FOUNDATION_EXPORT NSString *const VECTOR_TYPE_MICRON;
FOUNDATION_EXPORT NSString *const VECTOR_TYPE_NUMERICAL;
FOUNDATION_EXPORT NSString *const VECTOR_TYPE_PERCENTAGE;

@property (strong, nonatomic) StoredValueCurrency *currency;
@property (nonatomic) float magnitude;
@property (copy, nonatomic) NSString *type;

@end
