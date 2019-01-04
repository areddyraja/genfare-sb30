//
//  RequestNewCardService.m
//  CooCooBase
//
//  Created by Andrey Kasatkin on 3/22/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "RequestNewCardService.h"
#import "CooCooAccountUtilities1.h"
#import "Utilities.h"
#import "StoredData.h"
#import "Card.h"

@implementation RequestNewCardService
{
    NSString *nickname;
    NSString *description;
    NSNumber *personId;
    NSString *uuid;

}

- (id)initWithListener:(id)lis
              nickname:(NSString *)name
           description:(NSString *)desc
  managedObjectContext:(NSManagedObjectContext *)context
                  uuid:(NSString *)deviceUUID
                  personId:(NSNumber *)accountId;
{
    self = [super init];
    if (self) {
        self.method = METHOD_POST;
        self.listener = lis;
        nickname = name;
        description = desc;
        self.managedObjectContext = context;
        uuid = deviceUUID;
        personId = accountId;
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
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"services/data-api/mobile/wallets?tenant=%@",tenantId];
    //return @"services/data-api/mobile/wallets?tenant=COTA";
}

- (NSDictionary *)createRequest
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            personId, @"personId",
            nickname, @"nickname",
            uuid, @"deviceUUID",
            nil];
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
    NSLog(@"RequestNewCardService result: %@", serverResult);
    
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        if ([self setDataWithJson:[json valueForKey:@"result"]])
            return YES;
    }
    
    return NO;
}

- (BOOL)setDataWithJson:(NSDictionary *)json
{
    BOOL success = NO;
    
    Card *card = (Card *)[NSEntityDescription insertNewObjectForEntityForName:CARD_MODEL inManagedObjectContext:self.managedObjectContext];
    [card setIsTemporary:[NSNumber numberWithBool:NO]];
    [card setHuuid:[json valueForKey:@"huuid"]];
    [card setCvv:[json valueForKey:@"cvv"]];
    [card setState:[json valueForKey:@"state"]];
    
    [card setWalletId:[json valueForKey:@"id"]];
    [card setWalletUuid:[json valueForKey:@"walletUUID"]];
    [card setAccountId:[json valueForKey:@"personId"]];
    [card setNickname:[json valueForKey:@"nickname"]];
    [card setUuid:[json valueForKey:@"deviceUUID"]];
    [[NSUserDefaults standardUserDefaults] setValue:[json valueForKey:@"id"] forKey:@"WALLET_ID"];
     [[NSUserDefaults standardUserDefaults] setValue:[json valueForKey:@"printedId"] forKey:@"WALLETPRINT_ID"];

    /*
    Account *account = (Account *)[NSEntityDescription insertNewObjectForEntityForName:ACCOUNT_MODEL
                                                                inManagedObjectContext:managedObjectContext];
    [account setUuid:[json valueForKey:@"deviceUUID"]];
    */

    NSDate *createdDate = [Utilities dateFromUTCString:[json valueForKey:@"created"]];
    NSDate *modifiedDate = [Utilities dateFromUTCString:[json valueForKey:@"modified"]];
    
    [card setCreatedDateTime:createdDate];
    [card setModifiedDateTime:modifiedDate];
    
    if (![[json valueForKey:@"nickname"] isEqual:[NSNull null]]) {
        [card setNickname:[json valueForKey:@"nickname"]];
    }
    
    if (![[json valueForKey:@"description"] isEqual:[NSNull null]]) {
        [card setCardDescription:[json valueForKey:@"description"]];
    }
    
    if (![[json valueForKey:@"wallet"] isEqual:[NSNull null]]) {
        NSDictionary *walletJson = [json objectForKey:@"wallet"];
        
//        [card setWalletUuid:[walletJson objectForKey:@"uuid"]];
        [card setWalletUuid:[json valueForKey:@"walletUUID"]];
        [card setWalletHuuid:[walletJson objectForKey:@"huuid"]];
    }
    
    NSDictionary *accountObject = [json valueForKey:@"account"];
    
    if (![[json valueForKey:@"account"] isEqual: [NSNull null]]) {
        [card setAccountEmail:[accountObject valueForKey:@"email_address"]];
//        [card setAccountId:[accountObject valueForKey:@"uuid"]];
        [card setAccountId:[json valueForKey:@"personId"]];

        
        if (![[accountObject valueForKey:@"authorization"] isEqual: [NSNull null]]){
            [card setAccountAuthToken:[[accountObject valueForKey:@"authorization"] valueForKey:@"token"]];
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

@end
