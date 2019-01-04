//
//  WalletContent.m
//  CooCooBase
//
//  Created by Gaian Solutions on 4/12/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "WalletContent.h"

@implementation WalletContent



- (id)initWithDictionary:(NSDictionary*)dict1 {
    if ((self = [super init]))
    {
        @try {
            
           
            self.walletId=dict1[@"walletId"];
            self.walletUUID=dict1[@"walletUUID"];
            self.printedId=dict1[@"printedId"];
            self.statusId=dict1[@"statusId"];
            self.personId=dict1[@"personId"];
            self.farecode=dict1[@"farecode"];
            self.nickname=dict1[@"nickname"];
            self.status=dict1[@"status"];
            self.deviceUUID=dict1[@"deviceUUID"];
            self.deviceId=dict1[@"deviceId"];
            self.accountType=dict1[@"accountType"];
            self.accTicketGroupId=dict1[@"accTicketGroupId"];
            self.accMemberId=dict1[@"accMemberId"];
            self.cardType=dict1[@"cardType"];
            self.farecodeExpiryDateTime=dict1[@"farecode_expiry"];
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
