//
//  PayAsYouGoTicket.h
//  CDTATicketing
//
//  Created by CooCooTech on 8/26/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoredValueProduct.h"

@interface PayAsYouGoTicket : NSObject

@property (strong, nonatomic) StoredValueProduct *storedValueProduct;
@property (nonatomic) int riderCount;
@property (nonatomic) float totalFareAmount;

@end
