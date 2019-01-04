//
//  StoredValueSyncService.m
//  CDTATicketing
//
//  Created by CooCooTech on 10/6/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "StoredValueSyncService.h"
#import "StoredValueAccount.h"
#import "Tenant.h"

@implementation StoredValueSyncService
{

    StoredValueEvent *storedValueEvent;
    NSString *cardUuid;
}

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)context
      storedValueEvent:(StoredValueEvent *)event
                cardUuid:(NSString *)cardId;
{
    self = [super init];
    if (self) {
        self.method = METHOD_POST;
        self.listener = listener;
        self.managedObjectContext  = context;
        storedValueEvent = event;
        cardUuid = cardId;
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
    return [NSString stringWithFormat:@"app/wallet/stored_value/events/%@", cardUuid];
}

- (NSDictionary *)headers
{
    return nil;
}

- (NSDictionary *)createRequest
{
    NSFetchRequest *accountFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *accountEntity = [NSEntityDescription entityForName:STORED_VALUE_ACCOUNT_MODEL
                                                     inManagedObjectContext:self.managedObjectContext];
    [accountFetchRequest setEntity:accountEntity];
    
    NSError *error;
    NSArray *accounts = [self.managedObjectContext executeFetchRequest:accountFetchRequest error:&error];
    
    StoredValueAccount *account;
    for (StoredValueAccount *thisStoredValueAccount in accounts) {
        if ([thisStoredValueAccount.association isEqualToString: cardUuid ]) {
            account = thisStoredValueAccount;
        }
    }

    if (account) {
        NSMutableDictionary *requestJson = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *accountArray = [[NSMutableArray alloc] init];
        
        NSSet *events = [account events];
        
        for (StoredValueEvent *event in events) {
            NSMutableDictionary *eventJson = [[NSMutableDictionary alloc] init];
            
            [eventJson setObject:event.amount forKey:@"amount"];
            [eventJson setObject:event.type forKey:@"type"];
            
            NSMutableDictionary *targetAccountJson = [[NSMutableDictionary alloc] init];
            
            [targetAccountJson setObject:event.accountId forKey:@"id"];
            
            NSMutableDictionary *tenantJson = [[NSMutableDictionary alloc] init];
            
            [tenantJson setObject:event.tenantId forKey:@"id"];
            
            [targetAccountJson setObject:tenantJson forKey:@"tenant"];
            
            [eventJson setObject:targetAccountJson forKey:@"target"];
            
            [accountArray addObject:eventJson];
        }
        
        [requestJson setObject:accountArray forKey:@"account"];
        
        return requestJson;
    }
    
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
    if (serverResult) {
        [self deleteOldEvents];
        
        return YES;
    }
    
    return YES;
}

#pragma mark - Other methods

- (void)deleteOldEvents
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:STORED_VALUE_EVENT_MODEL];
    
    NSError *error = nil;
    NSArray *events = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (StoredValueEvent *event in events) {
        [self.managedObjectContext deleteObject:event];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end
