//
//  StoredValueCurrency.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/20/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoredValueCurrency : NSObject <NSCoding>

@property (nonatomic) int currencyId;
@property (copy, nonatomic) NSString *symbol;
@property (nonatomic) BOOL isPrefix;
@property (nonatomic) float modifierPercentage;

@end
