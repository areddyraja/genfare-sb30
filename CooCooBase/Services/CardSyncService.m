//
//  CardSyncService.m
//  CooCooBase
//
//  Created by CooCooTech on 5/10/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CardSyncService.h"
#import "AFNetworking.h"
#import "BaseService.h"
#import "CardEvent.h"
#import "CardEventContent.h"
#import "RuntimeData.h"
#import "Utilities.h"

@implementation CardSyncService
{
    NSManagedObjectContext *managedObjectContext;
    NSString *cardUuid;
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        managedObjectContext = context;
        cardUuid = [RuntimeData ticketSourceId:managedObjectContext];
    }
    
    return self;
}

- (NSArray *)createRequestWithQueue:(NSArray *)cardEvents
{
    NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    for (CardEvent *cardEvent in cardEvents) {
        NSMutableDictionary *eventJson = [[NSMutableDictionary alloc] init];
        
        [eventJson setObject:[formatter stringFromDate:cardEvent.occurredOnDateTime] forKey:@"occurred_on"];
        [eventJson setObject:cardEvent.type forKey:@"type"];
        [eventJson setObject:cardEvent.detail forKey:@"detail"];
        [eventJson setObject:cardEvent.code forKey:@"code"];
        
        CardEventContent *content = [NSKeyedUnarchiver unarchiveObjectWithData:cardEvent.content];
        
        NSMutableDictionary *contentJson = [[NSMutableDictionary alloc] init];
        
        [contentJson setObject:content.ticketGroupId forKey:@"ticket_group_id"];
        [contentJson setObject:content.memberId forKey:@"member_id"];
        [contentJson setObject:[formatter stringFromDate:content.bornOnDateTime] forKey:@"born_on"];
        
        CardEventFare *fare = content.fare;
        
        NSMutableDictionary *fareJson = [[NSMutableDictionary alloc] init];
        
        [fareJson setObject:fare.code forKey:@"code"];
        
        CardEventRevision *revision = fare.revision;
        
        NSMutableDictionary *revisionJson = [[NSMutableDictionary alloc] init];
        
        [revisionJson setObject:[NSNumber numberWithLong:revision.revisionId] forKey:@"id"];
        
        [fareJson setObject:revisionJson forKey:@"revision"];
        
        [contentJson setObject:fareJson forKey:@"fare"];
        
        [eventJson setObject:contentJson forKey:@"content"];
        
        [eventsArray addObject:eventJson];
    }
    
    NSLog(@"CardSyncService request: %@", [eventsArray copy]);
    
    return [eventsArray copy];
}

- (void)execute
{
    NSFetchRequest *cardEventsFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *cardEventEntity = [NSEntityDescription entityForName:CARD_EVENT_MODEL
                                                       inManagedObjectContext:managedObjectContext];
    [cardEventsFetchRequest setEntity:cardEventEntity];
    
    NSError *error;
    NSArray *cardEvents = [managedObjectContext executeFetchRequest:cardEventsFetchRequest error:&error];
    
    if ([cardEvents count] > 0) {
        // Tag the subsequent code as a task that can continue running if app goes into background during execution
        _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [self endBackgroundTask];
        }];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [[manager requestSerializer] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
                                                                    password:[Utilities authPassword]];
        
        NSDictionary *headers = [Utilities headers:[NSString stringWithFormat:@"%@/card/%@/contents/events", [Utilities apiUrl], cardUuid]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [[manager responseSerializer] setAcceptableContentTypes:
         [NSSet setWithObjects:@"text/html", @"application/json", nil]];
        
        NSLog(@"posting to: %@", [NSString stringWithFormat:@"%@/card/%@/contents/events", [Utilities apiUrl], cardUuid]);
        
        [manager POST:[NSString stringWithFormat:@"%@/card/%@/contents/events", [Utilities apiUrl], cardUuid]
           parameters:[self createRequestWithQueue:cardEvents]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"CardSyncService RESPONSE: %@", responseObject);
                  
                  if ([BaseService isResponseOk:responseObject]) {
                      [self deleteOldEvents];
                      
                      if (self.listener != nil) {
                          [self.listener cardSyncThreadSuccessWithClass:self];
                      }
                  } else {
                      if (self.listener != nil) {
                          [self.listener cardSyncThreadErrorWithClass:self];
                      }
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"CardSyncService Base Error Req: %@, Response: %@",
                        [[NSString alloc] initWithData:operation.request.HTTPBody encoding:4],
                        operation.responseString);
                  
                  if (self.listener != nil) {
                      [self.listener cardSyncThreadErrorWithClass:self];
                  }
              }];
        
        // End task if app is still in foreground so resources may be deallocated by the OS
        [self endBackgroundTask];
    }
}

- (void)endBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
    _backgroundTask = UIBackgroundTaskInvalid;
}

#pragma mark - Other methods

- (void)deleteOldEvents
{
    NSLog(@"Delete old card events");
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:CARD_EVENT_MODEL];
    
    NSError *error = nil;
    NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (CardEvent *event in events) {
        [managedObjectContext deleteObject:event];
    }
    
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
}

@end
