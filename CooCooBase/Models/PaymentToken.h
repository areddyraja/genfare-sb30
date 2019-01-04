//
//  PaymentToken.h
//  CooCooBase
//
//  Created by John Scuteri on 8/6/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentToken : NSObject

@property (copy, nonatomic) NSNumber *entryID;
@property (copy, nonatomic) NSString *ccLast4;
@property (copy, nonatomic) NSString *accountName;
@property (copy, nonatomic) NSNumber *usedCount;
@property (copy, nonatomic) NSNumber *createdDate;
@property (nonatomic) bool active;
@property (copy, nonatomic) NSNumber *lastUpdatedDate;
@property (copy, nonatomic) NSString *ccType;
@property (copy, nonatomic) NSString *accountID;
@property (copy, nonatomic) NSString *transitToken;
@property (copy, nonatomic) NSString *transitID;

@end
