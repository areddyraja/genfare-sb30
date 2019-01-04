//
//  GetStoredValueAccountService.m
//  CDTATicketing
//
//  Created by CooCooTech on 9/30/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "GetStoredValueAccountService.h"
#import "StoredValueAccount.h"
#import "Tenant.h"

@implementation GetStoredValueAccountService
{
    NSString *cardId;
}

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)context
                cardId:(NSString *)card
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = listener;
        self.managedObjectContext = context;
        cardId = card;
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
    NSLog(@"StoredValueAccounts URI: %@", [NSString stringWithFormat:@"app/wallet/stored_value/accounts/%@", cardId]);
    
    return [NSString stringWithFormat:@"app/wallet/stored_value/accounts/%@", cardId];
}

- (NSDictionary *)headers
{
    return nil;
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    //NSLog(@"StoredValueAccounts result: %@", json);
    
    if ([BaseService isResponseOk:json]) {
        return [self setDataWithJson:[json valueForKey:@"result"]];
    }
    
    return NO;
}

#pragma mark - Other methods

- (BOOL)setDataWithJson:(NSDictionary *)json
{
    NSArray *accountsJson = [json valueForKey:@"accounts"];
    if (accountsJson != nil) {
        for (NSDictionary *accountJson in accountsJson) {
            NSString *association = [accountJson valueForKey:@"association"];
            
            if ([association caseInsensitiveCompare:cardId] == NSOrderedSame) {   // TODO: Should be case-sensitive
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:STORED_VALUE_ACCOUNT_MODEL
                                                          inManagedObjectContext:self.managedObjectContext];
                [fetchRequest setEntity:entity];
                
                NSError *error;
                NSArray *accounts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                
                int accountId = [[accountJson valueForKey:@"id"] intValue];
                StoredValueAccount *account = nil;
                
                if ([accounts count] > 0) {
                    for (StoredValueAccount *storedValueAccount in accounts) {
                        if ([storedValueAccount.accountId intValue] == accountId) {
                            account = storedValueAccount;
                            
                            break;
                        }
                    }
                } if (!account) {
                    account = (StoredValueAccount *)[NSEntityDescription insertNewObjectForEntityForName:STORED_VALUE_ACCOUNT_MODEL
                                                                                  inManagedObjectContext:self.managedObjectContext];
                }
                
                [account setAssociation:association];
                [account setAccountId:[NSNumber numberWithInt:accountId]];
                [account setOwner:[accountJson valueForKey:@"owner"]];
                [account setAmount:[accountJson valueForKey:@"amount"]];
                [account setState:[accountJson valueForKey:@"state"]];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                
                [account setCreatedDateTime:[formatter dateFromString:[accountJson valueForKey:@"created"]]];
                [account setModifiedDateTime:[formatter dateFromString:[accountJson valueForKey:@"modified"]]];
                
                Tenant *tenant = [[Tenant alloc] init];
                
                NSDictionary *tenantJson = [accountJson objectForKey:@"tenant"];
                
                [tenant setTenantId:[[tenantJson valueForKey:@"id"] intValue]];
                [tenant setName:[tenantJson valueForKey:@"name"]];
                [tenant setShortName:[tenantJson valueForKey:@"shortName"]];
                [tenant setTimeZone:[tenantJson valueForKey:@"timeZone"]];
                
                NSData *tenantData = [NSKeyedArchiver archivedDataWithRootObject:tenant];
                
                [account setTenant:tenantData];
                
                //NSError *error;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
                    
                    return NO;
                }
                
                return YES;
            }
        }
    }
    
    return NO;
}

@end
