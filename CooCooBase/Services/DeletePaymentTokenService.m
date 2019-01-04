//
//  DeletePaymentTokenService.m
//  CooCooBase
//
//  Created by John Scuteri on 8/11/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "DeletePaymentTokenService.h"
#import "Utilities.h"

@implementation DeletePaymentTokenService
{
    NSString *accountId;
    NSString *paymentId;
}

- (id)initWithListener:(id)lis
             accountId:(NSString *)account
        paymentTokenId:(NSString *)payment
{
    self = [super init];
    if (self) {
        self.listener = lis;
        accountId = account;
        paymentId = payment;
    }
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities apiHost];
}

- (NSString *)uri
{
    //Change when real endpoint is made
    return @"paymentinfo/accounttokens/deactivate";
}

- (NSDictionary *)createRequest
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            accountId, @"account_id",
            paymentId, @"transaction_id",

            nil];
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        return YES;
    }
    
    return NO;
}

@end
