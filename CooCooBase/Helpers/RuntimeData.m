//
//  RuntimeData.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "RuntimeData.h"
#import "Utilities.h"

@implementation RuntimeData

NSString *const USER_DEFAULTS_TICKET_SOURCE_ID = @"ticketSourceId";

+ (id)instance
{
    static RuntimeData *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[super alloc] init];
        
        instance.busRoutes = [[NSArray alloc] init];
        instance.busLocations = [[NSArray alloc] init];
        instance.busPredictions = [[NSArray alloc] init];
        instance.appExceptions = [[NSArray alloc] init];
        instance.appMessages = [[NSArray alloc] init];
        instance.ticketEvents = [[NSArray alloc] init];
        instance.paymentTokens = [[NSArray alloc] init];
        instance.registeredDevices = [[NSArray alloc] init];
    });
    
    return instance;
}

+ (NSString *)ticketSourceId:(NSManagedObjectContext *)managedObjectContext
{
    NSMutableArray *cards = [[NSMutableArray alloc] initWithArray:[Utilities getCards:managedObjectContext]];
    
    if ([cards count] > 0) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_TICKET_SOURCE_ID];
    }
    
    return [Utilities deviceId];
}

+ (void)commitTicketSourceId:(NSString *)ticketSourceId
{
    [[NSUserDefaults standardUserDefaults] setValue:ticketSourceId forKey:USER_DEFAULTS_TICKET_SOURCE_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
