//
//  GetCardsForAccountService.m
//  CooCooBase
//
//  Created by CooCooTech on 3/29/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "GetCardsForAccountService.h"
#import "Card.h"
#import "Utilities.h"

@implementation GetCardsForAccountService
{
    NSString *accountId;
 }

- (id)initWithListener:(id)listener
             accountId:(NSString *)account
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = listener;
        accountId = account;
        self.managedObjectContext = context;
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
    NSString *accountParams = @"";
    if ([accountId length] > 0) {
        accountParams = [NSString stringWithFormat:@"/account/%@",accountId];
    }
    
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"cards%@?tenant=%@", accountParams,tenantId];
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
    //NSLog(@"GetCardsForAccountService result: %@", serverResult);
    return YES;
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        NSArray *result = [json valueForKey:@"result"];
        if ([result count] > 0) {
            [self deleteTemporaryCards];
            
            return [self setDataWithJson:result];
        }
        
        return YES;
    }
    
    return NO;
}


- (BOOL)setDataWithJson:(NSArray *)result
{
    BOOL success = NO;
    
    NSUInteger count = result.count;
    
    for (int i = 0; i < count; i++) {
        NSDictionary *cardDict = result[i];
        
        Card *card = (Card *)[NSEntityDescription insertNewObjectForEntityForName:CARD_MODEL inManagedObjectContext:self.managedObjectContext];
        [card setIsTemporary:[NSNumber numberWithBool:YES]];
        [card setUuid:[cardDict valueForKey:@"uuid"]];
        [card setHuuid:[cardDict valueForKey:@"huuid"]];
        [card setCvv:[cardDict valueForKey:@"cvv"]];
        [card setState:[cardDict valueForKey:@"state"]];
        
        NSDate *createdDate = [Utilities dateFromUTCString:[cardDict valueForKey:@"created"]];
        NSDate *modifiedDate = [Utilities dateFromUTCString:[cardDict valueForKey:@"modified"]];
        
        [card setCreatedDateTime:createdDate];
        [card setModifiedDateTime:modifiedDate];
        
        if (![[cardDict valueForKey:@"nickname"] isEqual:[NSNull null]]) {
            [card setNickname:[cardDict valueForKey:@"nickname"]];
        }
        
        if (![[cardDict valueForKey:@"description"] isEqual:[NSNull null]]) {
            [card setCardDescription:[cardDict valueForKey:@"description"]];
        }
        
        if (![[cardDict valueForKey:@"wallet"] isEqual:[NSNull null]]) {
            NSDictionary *walletJson = [cardDict objectForKey:@"wallet"];
            
            [card setWalletUuid:[walletJson objectForKey:@"uuid"]];
            [card setWalletHuuid:[walletJson objectForKey:@"huuid"]];
        } else {
            [card setWalletUuid:@""];
            [card setWalletHuuid:@""];
        }
        
        NSDictionary *accountObject = [cardDict valueForKey:@"account"];
        
        if (![[cardDict valueForKey:@"account"] isEqual: [NSNull null]]) {
            [card setAccountEmail:[accountObject valueForKey:@"email_address"]];
            [card setAccountId:[accountObject valueForKey:@"uuid"]];
            
            if (![[accountObject valueForKey:@"authorization"] isEqual: [NSNull null]]){
                [card setAccountAuthToken:[[accountObject valueForKey:@"authorization"] valueForKey:@"token"]];
            }
        }
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    } else {
        success = YES;
    }
    
    return success;
}

- (void)deleteTemporaryCards
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:CARD_MODEL inManagedObjectContext:self.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isTemporary == 1"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *cards = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Card *card in cards) {
        [self.managedObjectContext deleteObject:card];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end
