//
//  SavedCards.h
//  CooCooBase
//
//  Created by Gaian Solutions on 4/17/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedCards : NSObject
@property (copy, nonatomic) NSString *lastFour;
@property (copy, nonatomic) NSNumber *paymentTypeId;
@property (copy, nonatomic) NSNumber *cardNumber;
@property (copy, nonatomic) NSString *cardType;
@property (copy, nonatomic) NSString *expriredate;
- (id)initWithDictionary:(NSDictionary*)dict;
@end
