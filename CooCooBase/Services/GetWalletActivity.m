//
//  LoginService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetWalletActivity.h"
#import "WalletActivity.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"


@implementation GetWalletActivity
{
 
}

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)context

{
    self = [super init];
    if (self) {
        self.method=METHOD_GET;
        self.listener = lis;
        self.managedObjectContext = context;
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
    return [NSString stringWithFormat:@"services/data-api/mobile/wallets/%@/activity/after/0?tenant=%@",walletid,tenantId];
}

- (NSDictionary *)createRequest
{
    return  nil;
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
     NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
  //  json = [json dictionaryRemovingNSNullValues];
    NSLog(@"GetWalletactivity result for created user: %@", serverResult);
     NSArray *server = [json objectForKey:@"result"];
    if (server.count >0) {
        [[NSUserDefaults standardUserDefaults]setObject:serverResult forKey:@"WALLET_CONTENTS"];
        [self setDataWithJson:server];
        
        return YES;
    }

    return NO;
}
- (BOOL)setDataWithJson:(NSArray *)result
{
    BOOL sucess = NO;
    NSUInteger count = result.count;
    NSFetchRequest *getWalletActivityService = [[NSFetchRequest alloc] init];
    [getWalletActivityService setEntity:[NSEntityDescription entityForName:WALLET_ACTIVITY_MODEL inManagedObjectContext:self.managedObjectContext]];
    [getWalletActivityService setIncludesPropertyValues:NO];
    NSError *error = nil;
    NSArray *walletActivities = [self.managedObjectContext executeFetchRequest:getWalletActivityService error:&error];
    for (NSManagedObject *walletActivity in walletActivities) {
        [self.managedObjectContext deleteObject:walletActivity];
    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    
    for (int i = 0; i < count; i++) {
        NSDictionary *productDict = result[i];
        
        WalletActivity *walletactivity = (WalletActivity *)[NSEntityDescription insertNewObjectForEntityForName:WALLET_ACTIVITY_MODEL inManagedObjectContext:self.managedObjectContext];
        
        if(![[productDict valueForKey:@"activityId"] isEqual:[NSNull null]]){
            [walletactivity setActivityId:[productDict valueForKey:@"activityId"]];
        }
        if(![[productDict valueForKey:@"activityTypeId"]isEqual:[NSNull null]]){
            [walletactivity setActivityTypeId:[productDict valueForKey:@"activityTypeId"]];
       }
        if(![[productDict valueForKey:@"amountCharged"]isEqual:[NSNull null]]){
            [walletactivity setAmountCharged:[productDict valueForKey:@"amountCharged"]];
        }
        if(![[productDict valueForKey:@"amountRemaining"]isEqual:[NSNull null]]){
            [walletactivity setAmountRemaining:[productDict valueForKey:@"amountRemaining"]];
        }
        if(![[productDict valueForKey:@"date"]isEqual:[NSNull null]]){
            
            [walletactivity setDate:[productDict valueForKey:@"date"]];
        }
        if(![[productDict valueForKey:@"event"]isEqual:[NSNull null]]){
            [walletactivity setEvent:[productDict valueForKey:@"event"]];
        }
        if(![[productDict valueForKey:@"ticketId"]isEqual:[NSNull null]]){
            [walletactivity setTicketId:[productDict valueForKey:@"ticketId"]];
        }
        NSError *error1;
        if(![self.managedObjectContext save:&error1]){
            NSLog(@"error,couldn't save:%@",[error1 localizedDescription ]);
        }else{
            sucess = YES;
        }
    }
    return sucess;
}

@end

