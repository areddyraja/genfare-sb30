//
//  GetStatusOfUserWallet.m
//  CDTATicketing
//
//  Created by vishnu on 31/12/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

#import "GetStatusOfUserWallet.h"
#import "Utilities.h"
#import "CooCooAccountUtilities1.h"
#import "Wallet.h"

@implementation GetStatusOfUserWallet{
    NSString *wallet_Id;
}
- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext withwalletid:(NSString *)walletID{
    self = [super init];
    if (self) {
        self.method = METHOD_GET;
        self.listener = listener;
        self.managedObjectContext = managedContext;
        wallet_Id = walletID;
    }
    
    return self;
}

#pragma mark - Class overrides
- (NSString *)host{
    return [Utilities apiHost];
}

- (NSString *)uri
{
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"services/data-api/mobile/wallets/%@?tenant=%@", wallet_Id,tenantId];
}

- (NSDictionary *)createRequest
{
    return nil;
}
- (NSDictionary *)headers{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    NSString * base64String = [Utilities accessToken];
    [headers setValue:[NSString stringWithFormat:@"bearer %@", base64String] forKey:@"Authorization"];
    [headers setValue:@"application/json" forKey:@"Accept"];
    return headers;
}
- (BOOL)processResponse:(id)serverResult{
    NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    NSDictionary *productDict = [json objectForKey:@"result"];
    NSString *type = [productDict valueForKey:@"accountType"];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    account.profileType = [NSString stringWithFormat:@"%@",type];
    account.walletname= [NSString stringWithFormat:@"%@",[productDict valueForKey:@"nickname"]];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:WALLET_MODEL];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@",[productDict valueForKey:@"id"]]];
    NSError *error = nil;
    NSArray *walletarray = [self.managedObjectContext executeFetchRequest:request error:&error];
    Wallet *wallet;
    if(walletarray.count>0){
        wallet = [walletarray firstObject];
    }
    else{
        wallet = (Wallet *)[NSEntityDescription insertNewObjectForEntityForName:WALLET_MODEL inManagedObjectContext:self.managedObjectContext];
    }
    if (![[productDict valueForKey:@"id"] isEqual:[NSNull null]]) {
        [wallet setId:[productDict valueForKey:@"id"]];
    }
    if (![[productDict valueForKey:@"statusId"] isEqual:[NSNull null]]) {
        [wallet setStatusId:[productDict valueForKey:@"statusId"]];
    }
    if (![[productDict valueForKey:@"nickname"] isEqual:[NSNull null]]) {
        [wallet setNickname:[productDict valueForKey:@"nickname"]];
    }
    if (![[productDict valueForKey:@"status"] isEqual:[NSNull null]]) {
        [wallet setStatus:[productDict valueForKey:@"status"]];
    }
    if (![[productDict valueForKey:@"cardType"] isEqual:[NSNull null]]) {
        [wallet setCardType:[productDict valueForKey:@"cardType"]];
    }
    if (![[productDict valueForKey:@"accountType"] isEqual:[NSNull null]]) {
        [wallet setAccountType:[productDict valueForKey:@"accountType"]];
    }
    if (![[productDict valueForKey:@"walletUUID"] isEqual:[NSNull null]]) {
        [wallet setWalletUUID:[productDict valueForKey:@"walletUUID"]];
    }
    if (![[productDict valueForKey:@"farecode_expiry"] isEqual:[NSNull null]]) {
        [wallet setFarecodeExpiryDateTime:[NSNumber numberWithDouble:[[productDict valueForKey:@"farecode_expiry"] doubleValue]/1000]];
    }
    [[NSUserDefaults standardUserDefaults]setObject:[productDict valueForKey:@"cardType"] forKey:@"WALLETCARDTYPE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([[productDict valueForKey:@"deviceUUID"] isKindOfClass:[NSNull class]]){
    }
    else if([[productDict valueForKey:@"deviceUUID"] isEqualToString:[Utilities deviceId]]){
        if (![productDict[@"accMemberId"] isEqual:[NSNull null]] || ![productDict[@"accTicketGroupId"] isEqual:[NSNull null]]) {
            [[NSUserDefaults standardUserDefaults] setObject:productDict[@"accMemberId"] forKey:@"accmemberid"];
            [[NSUserDefaults standardUserDefaults] setObject:productDict[@"accTicketGroupId"] forKey:@"accticketgroupid"];
            [[NSUserDefaults standardUserDefaults] setValue:productDict[@"printedId"] forKey:@"WALLETPRINT_ID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

@end
