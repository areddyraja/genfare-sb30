//
//  SavedCards.m
//  CooCooBase
//
//  Created by Gaian Solutions on 4/17/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "SavedCards.h"

@implementation SavedCards

- (id)initWithDictionary:(NSDictionary*)dict {
    if ((self = [super init]))
    {
        @try {
            
             self.paymentTypeId=dict[@"paymentTypeId"];
             self.cardType=dict[@"cardType"];
            self.lastFour=dict[@"lastFour"];
            self.cardNumber=dict[@"cardNumber"];
            self.expriredate=dict[@"dateExpires"];
            
        }
        @catch (NSException *exception) {
            //Handle an exception thrown in the @try block
        }
        @finally {
            //  Code that gets executed whether or not an exception is thrown
        }
    }
    return self;
}
@end
