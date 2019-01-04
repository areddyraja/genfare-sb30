//
//  CardSaveforFuture.m
//  CooCooBase
//
//  Created by Reddy Raja on 4/18/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "CardSaveforFuture.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"

@implementation CardSaveforFuture
{
    
}

- (id)initWithListener:(id)lis

{
    self = [super init];
    if (self) {
        self.method=METHOD_POST;
        self.listener = lis;
        
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities dev_ApiHost];
}

- (NSString *)uri
{
    NSString *walletIdOfsavedcard  =  [[NSUserDefaults standardUserDefaults] valueForKey:@"WALLET_ID"];
    NSString *orderIdOfsavedcard  =  [[NSUserDefaults standardUserDefaults] valueForKey:@"ORDER_ID"];
    NSString *ischecked  =  [[NSUserDefaults standardUserDefaults] valueForKey:@"IS_CHECKED"];
    NSString *tenantId = [Utilities tenantId];

     return [NSString stringWithFormat:@"services/data-api/mobile/payment/page?tenant=%@&orderId=%@&walletId=%@&saveForFuture=%@",tenantId,orderIdOfsavedcard,walletIdOfsavedcard,ischecked];
    // return [NSString stringWithFormat:@"services/data-api/mobile/payment/options?tenant=CDTA"];
}

- (NSDictionary *)headers
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    NSString * base64String = [Utilities accessToken];
    [headers setValue:[NSString stringWithFormat:@"bearer %@", base64String] forKey:@"Authorization"];
    [headers setValue:@"application/json" forKey:@"Accept"];
    return headers;
}

- (BOOL)processResponse:(id)serverResult
{
    NSLog(@"Getcards: %@", serverResult);
    return NO;
}


@end
