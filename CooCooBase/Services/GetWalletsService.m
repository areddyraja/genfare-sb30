//
//  GetWalletsService.m
//  CooCooBase
//
//  Created by CooCooTech on 3/7/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "GetWalletsService.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"
#import "Wallet.h"
#import "SSKeychain.h"
#import "Account.h"
#import "CooCooAccountUtilities1.h"s
@implementation GetWalletsService
{
    NSString *nickname;
    NSNumber *personId;
     NSString *uuid;
    
}

- (id)initWithListener:(id)lis
              nickname:(NSString *)name
  managedObjectContext:(NSManagedObjectContext *)context
                  uuid:(NSString *)deviceUUID
              personId:(NSNumber *)accountId;
{
    self = [super init];
    if (self) {
       self.method = METHOD_POST;
        self.listener = lis;
        nickname = name;
        self.managedObjectContext = context;
        uuid = deviceUUID;
        personId = accountId;
    }
    
    return self;
}


#pragma mark - Class overrides

- (NSString *)host
{
   // return [Utilities apiHost];
    return [Utilities dev_ApiHost];
    
}

- (NSString *)uri
{
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"services/data-api/mobile/wallets/?tenant=%@",tenantId];
}

- (NSDictionary *)createRequest
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            nickname, @"nickname",uuid, @"deviceUUID",personId, @"personId",
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
    NSLog(@"GetWalletsService result: %@", serverResult);
    NSMutableDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

    NSDictionary *json = [jsonDict valueForKey:@"result"];
    [self setDataWithJson:json];

//    if ([BaseService isResponseOk:json]) {
//        [self setDataWithJson:json];
//
//        return YES;
//    }
    
    return YES;
}

#pragma mark - Other methods
- (BOOL)setDataWithJson:(NSDictionary *)json
{
    BOOL success = NO;
    
    NSLog(@"json is:%@",json);
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:WALLET_MODEL];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@",[json valueForKey:@"id"]]];
    NSError *error = nil;
    NSArray *walletarray = [self.managedObjectContext executeFetchRequest:request error:&error];
    Wallet *wallet;
    if(walletarray.count>0){
        wallet = [walletarray firstObject];
    }
    else{
        wallet = (Wallet *)[NSEntityDescription insertNewObjectForEntityForName:WALLET_MODEL inManagedObjectContext:self.managedObjectContext];
    }
   
    [[NSUserDefaults standardUserDefaults] setValue:[json valueForKey:@"id"] forKey:@"WALLET_ID"];
     [[NSUserDefaults standardUserDefaults] setValue:[json valueForKey:@"printedId"] forKey:@"WALLETPRINT_ID"];

    if (![[json valueForKey:@"id"] isEqual:[NSNull null]]) {
        [wallet setId:[json valueForKey:@"id"]];
    }
    if (![[json valueForKey:@"deviceUUID"] isEqual:[NSNull null]]) {
        [wallet setDeviceUUID:[json valueForKey:@"deviceUUID"]];
    }
    if (![[json valueForKey:@"nickname"] isEqual:[NSNull null]]) {
        [wallet setNickname:[json valueForKey:@"nickname"]];
    }
    if (![[json valueForKey:@"status"] isEqual:[NSNull null]]) {
        [wallet setStatus:[json valueForKey:@"status"]];
    }
    if (![[json valueForKey:@"personId"] isEqual:[NSNull null]]) {
        [wallet setPersonId:[json valueForKey:@"personId"]];
    }
    if (![[json valueForKey:@"statusId"] isEqual:[NSNull null]]) {
        [wallet setStatusId:[json valueForKey:@"statusId"]];
    }
    if (![[json valueForKey:@"walletUUID"] isEqual:[NSNull null]]) {
        [wallet setWalletUUID:[json valueForKey:@"walletUUID"]];
    }
    if (![[json valueForKey:@"cardType"] isEqual:[NSNull null]]) {
        [wallet setCardType:[json valueForKey:@"cardType"]];
    }
    if (![[json valueForKey:@"accountType"] isEqual:[NSNull null]]) {
        [wallet setAccountType:[json valueForKey:@"accountType"]];
    }
    
    
 
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    account.profileType = wallet.accountType;
    account.walletname=wallet.nickname;
    
    [[NSUserDefaults standardUserDefaults]setObject:wallet.cardType forKey:@"WALLETCARDTYPE"];
    [[NSUserDefaults standardUserDefaults] synchronize];


    
  //  [self saveToKeychain:[json valueForKey:@"deviceUUID"]];
    
     if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    } else {
        success = YES;
    }
    
    return success;
}

//-(void)saveToKeychain:(NSString *)walletUuid
//{
//    // Change default accessibilty permission to be always accessible
//    [SSKeychain setAccessibilityType:kSecAttrAccessibleAlways];
//
//    // Save the CFUUID string to keychain for persistence if user uninstalls the app
//    [SSKeychain setPassword:walletUuid forService:[[NSBundle mainBundle] bundleIdentifier] account:WALLET_MODEL];
//}

@end
