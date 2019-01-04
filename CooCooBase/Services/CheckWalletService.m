//
//  LoginService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CheckWalletService.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"
#import "Wallet.h"

@implementation CheckWalletService{
    NSString *emailid;
}
- (id)initWithListener:(id)lis
               emailid:(NSString *)email managedContext:(NSManagedObjectContext*)context{
    self = [super init];
    if (self) {
        self.method=METHOD_GET;
        self.listener = lis;
        self.managedObjectContext=context;
        emailid = email;
    }
    return self;
}
#pragma mark - Class overrides
- (NSString *)host{
    return [Utilities apiHost];
}
- (NSString *)uri{
    NSString *tenantId = [Utilities tenantId];
    NSLog(@"CheckWalletService_URL=%@",[NSString stringWithFormat:@"services/data-api/mobile/wallets/for/%@?tenant=%@",emailid,tenantId]);
    return [NSString stringWithFormat:@"services/data-api/mobile/wallets/for/%@?tenant=%@",emailid,tenantId];
}
- (NSDictionary *)createRequest{
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
//    json = [json dictionaryRemovingNSNullValues];
    NSArray *server = [json objectForKey:@"result"];
    if(server.count >0){
        for (int i = 0; i <server.count; i++) {
            NSDictionary *productDict = server[i];
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
            [[NSUserDefaults standardUserDefaults]setObject:[productDict valueForKey:@"cardType"] forKey:@"WALLETCARDTYPE"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if([[productDict valueForKey:@"deviceUUID"] isKindOfClass:[NSNull class]]){
            }
            else if([[productDict valueForKey:@"deviceUUID"] isEqualToString:[Utilities deviceId]]){
                if (![productDict[@"accMemberId"] isEqual:[NSNull null]] || ![productDict[@"accTicketGroupId"] isEqual:[NSNull null]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:productDict[@"accMemberId"] forKey:@"accmemberid"];
                    [[NSUserDefaults standardUserDefaults] setObject:productDict[@"accTicketGroupId"] forKey:@"accticketgroupid"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
             if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
                return NO;
            }
        }
    }
    return YES;
}
@end
