//
//  AssignCardService.m
//  CooCooBase
//
//  Created by Andrey Kasatkin on 3/25/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "AssignWalletApi.h"
#import "Utilities.h"

@implementation AssignWalletApi

{
    NSString *accountId;
 }

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
           accoundUuid:(NSString *)accountUuid
{
    self = [super init];
    if (self) {
        self.listener = lis;
        accountId = (NSString *)accountUuid;
        self.managedObjectContext = managedObjectContext;
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

    return [NSString stringWithFormat:@"services/data-api/mobile/wallets/%@/assignto/%@?tenant=%@",walletid, accountId, tenantId];
    
}

- (BOOL)processResponse:(id)serverResult
{
    NSLog(@"AssignCardService: %@", serverResult);
    
    NSDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    jsonDict = [jsonDict dictionaryRemovingNSNullValues];
    NSDictionary *json = [jsonDict valueForKey:@"result"];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    } else {
        return YES;
    }
    
    return NO;
}

@end
