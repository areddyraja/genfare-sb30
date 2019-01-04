//
//  GetTicketEventsService.m
//  CooCooBase
//
//  Created by CooCooTech on 6/20/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "GetTicketEventsService.h"
#import "RuntimeData.h"
#import "TicketEvent.h"
#import "Utilities.h"

@implementation GetTicketEventsService
{
    NSString *ticketGroupId;
    NSString *memberId;
}

- (id)initWithListener:(id)lis
         ticketGroupId:(NSString *)group
              memberId:(NSString *)member
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = lis;
        ticketGroupId = group;
        memberId = member;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities apiHost];
}

- (NSString *)uri
{
    return [NSString stringWithFormat:@"ticketevents/%@/%@", ticketGroupId, memberId];
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        [self setDataWithJson:[json valueForKey:@"result"]];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    NSMutableArray *ticketEvents = [[NSMutableArray alloc] init];
    
    for (NSDictionary *ticketEventJson in json) {
        TicketEvent *ticketEvent = [[TicketEvent alloc] init];
        
        [ticketEvent setCreatedDateTime:[[ticketEventJson objectForKey:@"createddatetime"] doubleValue]];
        
        
        @try {  // TODO: This was changed from an epoch timestamp to datetime string (at least in the DEMO API) at some point
                 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.S"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [ticketEvent setEventDateTime:[[formatter dateFromString:[ticketEventJson objectForKey:@"eventdatetime"]] timeIntervalSince1970]];
        }
        @catch (NSException *exception ){
                [ticketEvent setEventDateTime:[[ticketEventJson objectForKey:@"eventdatetime"] doubleValue]];
        }
        
        [ticketEvent setEventDetail:[ticketEventJson objectForKey:@"eventdetail"]];
        [ticketEvent setEventLat:[[ticketEventJson objectForKey:@"eventlat"] doubleValue]];
        [ticketEvent setEventLng:[[ticketEventJson objectForKey:@"eventlon"] doubleValue]];
        [ticketEvent setEventType:[ticketEventJson objectForKey:@"eventtype"]];
        [ticketEvent setMemberId:[ticketEventJson objectForKey:@"memberid"]];
        [ticketEvent setReportDeviceId:[ticketEventJson objectForKey:@"reportdeviceid"]];
        [ticketEvent setReportDeviceType:[ticketEventJson objectForKey:@"reportdevicetype"]];
        [ticketEvent setReportUserId:@""];
        [ticketEvent setTicketGroupId:[ticketEventJson objectForKey:@"ticketgroupid"]];
        [ticketEvent setTransitId:[ticketEventJson objectForKey:@"transitid"]];
        [ticketEvent setSynced:[NSNumber numberWithBool:YES]];
        
        [ticketEvents addObject:ticketEvent];
    }
    
    [[RuntimeData instance] setTicketEvents:ticketEvents];
}

@end
