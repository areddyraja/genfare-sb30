//
//  LoginService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetConfigApi.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"
#import "Singleton.h"

@implementation GetConfigApi
{
 
}

- (id)initWithListener:(id)lis
{
    self = [super init];
    if (self) {
        self.method=METHOD_GET;
        self.listener = lis;
        self.managedObjectContext = [[Singleton sharedManager] managedContext];
   
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
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"services/data-api/mobile/config?tenant=%@",tenantId];
}

- (NSDictionary *)createRequest
{
  
    return nil;
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
//    json = [json dictionaryRemovingNSNullValues];
 NSLog(@"Getconfig  parameters for created user: %@", serverResult);
     NSMutableDictionary *server = [json objectForKey:@"orderLimits"];
    if(server.count >0){
        NSMutableDictionary *walletMinnMax = [server objectForKey:@"registeredUser"];
        NSNumber *walletMin = [walletMinnMax objectForKey:@"min"];
        NSNumber *walletMax = [walletMinnMax objectForKey:@"max"];
        [[NSUserDefaults standardUserDefaults]setObject:walletMin forKey:@"Config_Min"];
        [[NSUserDefaults standardUserDefaults]setObject:walletMax forKey:@"Config_Max"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    NSNumber *offset = [json valueForKey:@"EndOfTransitDay"];
    NSNumber *transitid = [json valueForKey:@"TransitId"];
    NSNumber *agencyId = [json valueForKey:@"AgencyId"];
     NSString *AgencyContactNumber = [json valueForKey:@"AgencyContactNumber"];
    [[NSUserDefaults standardUserDefaults] setValue:agencyId forKey:@"AGENCY_ID"];
    [[NSUserDefaults standardUserDefaults] setValue:AgencyContactNumber forKey:@"AGENCY_CONTACT_NUMBER"];
    [[NSUserDefaults standardUserDefaults] setValue:offset forKey:@"OFFSET_VALUE"];
    [[NSUserDefaults standardUserDefaults] setValue:transitid forKey:@"TRANSIT_ID"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSDictionary *loyaltyProgram = [json valueForKey:@"LoyaltyProgram"];
    NSDictionary *cappedRide = [loyaltyProgram valueForKey:@"CAPPED_RIDE"];
    if (cappedRide) {
        NSNumber *cappedDelay = [cappedRide valueForKey:@"Delay"];
        NSString *cappedFareCode = [cappedRide valueForKey:@"FareCode"];
        NSNumber *cappedThreshold = [cappedRide valueForKey:@"Threshold"];
        NSNumber *cappedTicketId = [cappedRide valueForKey:@"TicketId"];
        if (([[cappedRide allKeys] containsObject:@"Delay"] && cappedDelay!=nil)  &&   ([[cappedRide allKeys] containsObject:@"FareCode"] && cappedFareCode!=nil)   && ([[cappedRide allKeys] containsObject:@"Threshold"] && cappedThreshold!=nil)  && ([[cappedRide allKeys] containsObject:@"TicketId"] && cappedTicketId!=nil)) {
            [[NSUserDefaults standardUserDefaults] setValue:cappedDelay forKey:@"CAPPED_DELAY"];
            if (cappedThreshold == 0) {
                cappedThreshold = [NSNumber numberWithInteger:-1];
            }
            [[NSUserDefaults standardUserDefaults] setValue:cappedThreshold forKey:@"CAPPED_THRESHOLD"];
            [[NSUserDefaults standardUserDefaults] setValue:cappedTicketId forKey:@"CAPPED_TICKETID"];
        }else{
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:-1] forKey:@"CAPPED_THRESHOLD"];
        }
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    NSDictionary *bonusRide = [loyaltyProgram valueForKey:@"BONUS_RIDE"];
    if (bonusRide) {
        NSNumber *bonusDelay = [bonusRide valueForKey:@"Delay"];
        NSString *bonusFareCode = [bonusRide valueForKey:@"FareCode"];
        NSNumber *bonusThreshold = [bonusRide valueForKey:@"Threshold"];
        NSNumber *bonusTicketId = [bonusRide valueForKey:@"TicketId"];
        if (([[bonusRide allKeys] containsObject:@"Delay"] && bonusDelay!=nil)  &&   ([[bonusRide allKeys] containsObject:@"FareCode"] && bonusFareCode!=nil)   && ([[bonusRide allKeys] containsObject:@"Threshold"] && bonusThreshold!=nil)  && ([[bonusRide allKeys] containsObject:@"TicketId"] && bonusTicketId!=nil)) {
            [[NSUserDefaults standardUserDefaults] setValue:bonusDelay forKey:@"BONUS_DELAY"];
            if (bonusThreshold == 0) {
                bonusThreshold = [NSNumber numberWithInteger:-1];
            }
            [[NSUserDefaults standardUserDefaults] setValue:bonusThreshold forKey:@"BONUS_THRESHOLD"];
            [[NSUserDefaults standardUserDefaults] setValue:bonusTicketId forKey:@"BONUS_TICKETID"];
        }else{
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:-1] forKey:@"BONUS_THRESHOLD"];
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:0] forKey:@"BONUS_DELAY"];
        }
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    return YES;
}

@end

