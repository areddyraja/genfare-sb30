//
//  TicketSyncService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TicketSyncService.h"
#import "AFNetworking.h"
#import "AppConstants.h"
#import "BaseService.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Ticket.h"
#import "Utilities.h"

NSString *const URI_TICKET_SYNC = @"ticketevents/add";

@implementation TicketSyncService
{
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *updatedTicketsQueue;
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        managedObjectContext = context;
        updatedTicketsQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSArray *)createRequestWithQueue:(NSArray *)ticketsQueue
{
    NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
    
    for (NSString *ticketId in ticketsQueue) {
        NSLog(@"looking at ticket ID: %@", ticketId);
        
        NSString *formattedTicketId = [ticketId stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"-%@", EVENT_TYPE_REDEEM] withString:@""];
        
        NSLog(@"formattedTicketId: %@", formattedTicketId);
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:TICKET_MODEL
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", formattedTicketId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *tickets = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([tickets count] > 0) {
            Ticket *ticket = [tickets objectAtIndex:0];
            
            // TODO: Determine if accountId still has any bearing on card-based ticket activations
            //       Comment out for now
            NSString *userIdValue = @"";
            /*NSString *userId = [StoredData userData].accountId;
            if (userId) {
                userIdValue = userId;
            }*/
            
            NSDictionary *eventDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                             ticket.ticketGroupId, @"ticketgroupid",
                                             ticket.memberId, @"memberid",
                                             [ticket.activationDateTime stringValue], @"eventdatetime",
                                             ([ticketId containsString:EVENT_TYPE_REDEEM] ? EVENT_TYPE_REDEEM : ticket.eventType), @"eventtype",
                                             @"Ticket activated", @"eventdetail",
                                             [ticket.eventLat stringValue], @"eventlat",
                                             [ticket.eventLng stringValue], @"eventlon",
                                             TYPE_APP, @"reportdevicetype",
                                             [Utilities deviceId], @"reportdeviceid",
                                             userIdValue, @"reportuserid",
                                             [Utilities transitId], @"transitid",
                                             ticket.ticketAmount, @"fare_amount",
                                             ticket.fareCode, @"fare_code",
                                             ticket.bfp, @"revision_id",
                                             nil];
            
            [eventsArray addObject:eventDictionary];
        } else if (![updatedTicketsQueue containsObject:ticketId]) {
            /*
             * TODO: Ticket that was in StoredData was not found in CoreData
             * This scenario has occured during development, possibly during an app
             * upgrade where CoreData was deleted but StoredData was not
             * We need to make sure this never happens in production
             */
            [updatedTicketsQueue addObject:ticketId];
            
            NSLog(@"added %@ to updatedTicketsQueue", ticketId);
        }
    }
    
    return [eventsArray copy];
}

- (void)execute
{
    NSArray *localTicketsQueue = [[StoredData ticketsQueue] copy];
    
    if ([localTicketsQueue count] > 0) {
        // Tag the subsequent code as a task that can continue running if app goes into background during execution
        _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [self endBackgroundTask];
        }];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [[manager requestSerializer] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
                                                                    password:[Utilities authPassword]];
        
        NSDictionary *headers = [Utilities headers:[NSString stringWithFormat:@"%@/%@", [Utilities apiUrl], URI_TICKET_SYNC]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [[manager responseSerializer] setAcceptableContentTypes:
         [NSSet setWithObjects:@"text/html", @"application/json", nil]];
        
        NSLog(@"TicketSyncQueue: %@", localTicketsQueue);
        NSLog(@"request: %@", [self createRequestWithQueue:localTicketsQueue]);
        NSLog(@"posting to: %@", [NSString stringWithFormat:@"%@/%@", [Utilities apiUrl], URI_TICKET_SYNC]);
        
        [manager POST:[NSString stringWithFormat:@"%@/%@", [Utilities apiUrl], URI_TICKET_SYNC]
           parameters:[self createRequestWithQueue:localTicketsQueue]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"TicketSyncService RESPONSE: %@", responseObject);
                  
                  if ([BaseService isResponseOk:responseObject]) {
                      if ([updatedTicketsQueue count] > 0) {
                          [StoredData commitTicketsQueueWithList:updatedTicketsQueue];
                      } else {
                          [StoredData removeTicketsQueue];
                      }
                      
                      if (self.listener != nil) {
                          [self.listener syncThreadSuccessWithClass:self];
                      }
                  } else {
                      if (self.listener != nil) {
                          [self.listener syncThreadErrorWithClass:self];
                      }
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"TicketSyncService Base Error Req: %@, Response: %@",
                        [[NSString alloc] initWithData:operation.request.HTTPBody encoding:4],
                        operation.responseString);
                  
                  if (self.listener != nil) {
                      [self.listener syncThreadErrorWithClass:self];
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

@end
