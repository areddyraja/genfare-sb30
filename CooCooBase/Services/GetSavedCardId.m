//
//  LoginService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetSavedCardId.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"


@implementation GetSavedCardId
{
    NSString *orderIdOfsavedcard;
    NSString *walletIdOfsavedcard;
    NSString *savedcardId;
    
}

- (id)initWithListener:(id)lis  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
               orderId:(NSString *)orderId walletId:(NSString *)WalletId savedCardId:(NSString *)savedCardId

{
    self = [super init];
    if (self) {
        self.method=METHOD_GET;
        self.listener = lis;
        savedcardId = (NSString *)savedCardId;
        orderIdOfsavedcard = (NSString *)orderIdOfsavedcard;
        walletIdOfsavedcard = (NSString *)WalletId;
        
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
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"http://api.staging.gfcp.io/services/data-api/mobile/payment/page?tenant=%@&orderId=%@&walletId=%@&savedCardId=%@",tenantId,orderIdOfsavedcard,walletIdOfsavedcard,savedcardId];
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
    NSLog(@"Getsavedcards: %@", serverResult);
    return NO;
}

@end

