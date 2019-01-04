//
//  LoginService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetWalletContentUsagePayAsYouGo.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"



@implementation GetWalletContentUsagePayAsYouGo
{

    NSString *walletContentUsageIdentifier;
    NSString *chargeDate;
     NSArray *walletBalanceArray;
    NSNumber *date;

    
}

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext withArray:(NSArray *)walletbalance walletContentUsageIdentifier:(id)walletContentUsageIdentifierid
{
    self = [super init];
    if (self) {
         self.method = METHOD_POST;
        self.listener = listener;
        self.managedObjectContext = managedContext;
    walletContentUsageIdentifier = walletContentUsageIdentifierid;
         walletBalanceArray = walletbalance;
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
    NSString *walletid = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"services/data-api/mobile/wallets/%@/contents/%@/charge?tenant=%@",walletid,walletContentUsageIdentifier,tenantId];
}

- (NSDictionary *)createRequest
{
    return walletBalanceArray;
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
    
    
    
   
    
    return YES;
}

@end

