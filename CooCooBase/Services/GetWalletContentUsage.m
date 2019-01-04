//
//  LoginService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetWalletContentUsage.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"


@implementation GetWalletContentUsage
{
    NSString *walletContentUsageIdentifier;
     NSArray *epochsecond;
    
}

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext withArray:(NSArray *)epochSeconds walletContentUsageIdentifier:(id)walletContentUsageIdentifierid
{
    self = [super init];
    if (self) {
        self.method = METHOD_POST;
        self.listener = listener;
        self.managedObjectContext = managedContext;
        epochsecond = epochSeconds;
         walletContentUsageIdentifier = walletContentUsageIdentifierid;
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

- (NSArray *)createRequest
{
    return  epochsecond;
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
    NSLog(@"wallet update %@",serverResult);
    return YES;
}

@end

