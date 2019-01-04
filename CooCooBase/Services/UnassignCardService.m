//
//  UnassignCardService.m
//  CooCooBase
//
//  Created by Andrey Kasatkin on 3/25/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "UnassignCardService.h"
#import "Utilities.h"
#import "Card.h"

@implementation UnassignCardService

{
    Card *card;
    NSString *accountId;
 }

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  card:(Card *)cardObject
           accoundUuid:(NSString *)accountUuid;
{
    self = [super init];
    if (self) {
        self.listener = lis;
        card = cardObject;
        accountId = accountUuid;
        self.managedObjectContext = managedObjectContext;
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
    return [NSString stringWithFormat:@"wallet/%@/account/%@/forget", card.uuid, accountId];
}

- (BOOL)processResponse:(id)serverResult
{
    NSLog(@"serverResult %@", serverResult);
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        
        card.accountId = nil;
        card.accountEmail = nil;
        card.accountAuthToken = nil;
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        } else {
            return YES;
        }
    }
    
    return NO;
}

@end
