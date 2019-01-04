//
//  AssignCardService.m
//  CooCooBase
//
//  Created by Andrey Kasatkin on 3/25/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "AssignCardService.h"
#import "Utilities.h"
@implementation AssignCardService

{
    Card *card;
    NSString *accountId;
 }

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  card:(Card *)cardObject
           accoundUuid:(NSString *)accountUuid
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
    return [NSString stringWithFormat:@"card/%@/account/%@", card.uuid, accountId];
}

- (BOOL)processResponse:(id)serverResult
{
    NSLog(@"AssignCardService: %@", serverResult);
    NSMutableDictionary *jsondict=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

    NSDictionary *json = [jsondict valueForKey:@"result"];
    
    NSDictionary *accountObject = [json valueForKey:@"account"];
    card.accountId = [accountObject valueForKey:@"uuid"];
    card.accountEmail = [accountObject valueForKey:@"email_address"];
    
    if (![[accountObject valueForKey:@"authorization"] isEqual:[NSNull null]]) {
        card.accountAuthToken = [[accountObject valueForKey:@"authorization"] valueForKey:@"token"];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    } else {
        return YES;
    }
    
    return NO;
}

@end

