//
//  StoredData.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "StoredData.h"

NSString *const KEY_USER_DATA = @"userData";
NSString *const KEY_TICKETS_LIST = @"ticketsList";
NSString *const KEY_TICKETS_QUEUE = @"ticketsQueue";
NSString *const KEY_TICKETS_HISTORY_LIST = @"ticketsHistoryList";
NSString *const KEY_CARD_EVENTS_QUEUE = @"cardEventsQueue";

@implementation StoredData {}

#pragma mark - UserData

+ (UserData *)userData
{
    UserData *userData = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:KEY_USER_DATA];
    
    if (encodedObject != nil) {
        userData = (UserData *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    
    if (userData == nil) {
        userData = [[UserData alloc] init];
        
        [self commitUserDataWithData:userData];
    }
    
    return userData;
}

+ (void)commitUserDataWithData:(UserData *)userData
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:userData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:KEY_USER_DATA];
    
    [defaults synchronize];
}

+ (void)removeUserData
{
    [self commitUserDataWithData:[[UserData alloc] init]];
}

#pragma mark - Ticket Activations Queue

+ (NSMutableArray *)ticketsQueue
{
    NSMutableArray *ticketsQueue = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_TICKETS_QUEUE] mutableCopy];
    
    if (ticketsQueue == nil) {
        ticketsQueue = [[NSMutableArray alloc] init];
        
        [self commitTicketsQueueWithList:ticketsQueue];
    }
    
    return ticketsQueue;
}

+ (void)commitTicketsQueueWithList:(NSMutableArray *)ticketsQueueList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[NSArray alloc] initWithArray:ticketsQueueList] forKey:KEY_TICKETS_QUEUE];
    
    [defaults synchronize];
}

+ (void)removeTicketsQueue
{
    [self commitTicketsQueueWithList:[[NSMutableArray alloc] init]];
}

#pragma mark - Card Events Queue

+ (NSMutableArray *)cardEventsQueue
{
    NSMutableArray *cardEventsQueue = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_CARD_EVENTS_QUEUE] mutableCopy];
    
    if (cardEventsQueue == nil) {
        cardEventsQueue = [[NSMutableArray alloc] init];
        
        [self commitCardEventsQueueWithList:cardEventsQueue];
    }
    
    return cardEventsQueue;
}

+ (void)commitCardEventsQueueWithList:(NSMutableArray *)cardEventsQueueList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[NSArray alloc] initWithArray:cardEventsQueueList] forKey:KEY_CARD_EVENTS_QUEUE];
    
    [defaults synchronize];
}

+ (void)removeCardEventsQueue
{
    [self commitCardEventsQueueWithList:[[NSMutableArray alloc] init]];
}

@end
