 //
//  CreateOrderService.m
//  CooCooBase
//
//  Created by IBase Software on 21/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "CreateOrderService.h"
#import "Utilities.h"
#import "CardSaveforFuture.h"
@implementation CreateOrderService
{
     NSArray *ticketsArray;
}
- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext withArray:(NSArray *)selectedTickets;
{
    self = [super init];
    if (self) {
        self.method = METHOD_POST;
        self.listener = listener;
        self.managedObjectContext = managedContext;
        ticketsArray = selectedTickets;
    }
    
    return self;
}

#pragma mark - Class overrides
- (NSSet *)createRequest
{
    return ticketsArray;
//    [NSDictionary dictionaryWithObjectsAndKeys:
//            accountid, @"id",
//            password, @"password",
//            firstName, @"firstName",
//            lastName, @"lastName",
//            nil];
}

- (NSString *)host
{
    return [Utilities dev_ApiHost];
}
- (NSDictionary *)headers
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    NSString * base64String = [Utilities accessToken];
    [headers setValue:[NSString stringWithFormat:@"bearer %@", base64String] forKey:@"Authorization"];
    [headers setValue:@"application/json" forKey:@"Accept"];
    return headers;
}
- (NSString *)uri
{
    NSString *walletID  =  [[ NSUserDefaults standardUserDefaults] valueForKey:@"WALLET_ID"];
    NSString *tenantId = [Utilities tenantId];

    NSLog(@"create order  URI: %@", [NSString stringWithFormat:@"/services/data-api/mobile/wallets/%@/order?tenant=%@", walletID,tenantId]);
    
    return [NSString stringWithFormat:@"/services/data-api/mobile/wallets/%@/order?tenant=%@", walletID,tenantId];

}

- (NSString *)uriSavedforfuture
{
    NSString *walletID  =  [[ NSUserDefaults standardUserDefaults] valueForKey:@"WALLET_ID"];
    NSString *orderID  =  [[ NSUserDefaults standardUserDefaults] valueForKey:@"ORDER_ID"];
    NSString *ischecked  =  [[ NSUserDefaults standardUserDefaults] valueForKey:@"IS_CHECKED"];
    NSString *tenantId = [Utilities tenantId];


    return [NSString stringWithFormat:@"/services/data-api/mobile/payment/%@/%@/%@/page?tenant=%@", walletID,orderID,ischecked, tenantId];
    
}

- (BOOL)processResponse:(id)serverResult
{
    //NSLog(@"GetCardsService result: %@", serverResult);
    
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    // if ([BaseService isResponseOk:json]) {
    //   if (![[json valueForKey:@"result"] isEqual:[NSNull null]]) {
    //    NSArray *result = [json valueForKey:@"result"];
    
    // [self deleteCards];
    [[NSUserDefaults standardUserDefaults]setObject:[json valueForKey:@"result"] forKey:@"ORDER_ID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
//    CardSaveforFuture *cardService = [[CardSaveforFuture alloc] initWithListener:self];
//    [cardService execute];
    
   // return [self setDataWithJson:serverResult];
    //  }
    
    return YES;
    //  }
    
    //  return NO;
}

- (BOOL)setDataWithJson:(NSArray *)result
{
    BOOL success = NO;
    
    NSUInteger count = result.count;
        
    
    
    return success;
}



@end
