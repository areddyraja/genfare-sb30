//
//  CustomerRequestService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CustomerRequestService.h"
#import "Utilities.h"

@implementation CustomerRequestService
{
    NSString *ticketGroupId;
    NSString *comment;
}

- (id)initWithListener:(id)lis
         ticketGroupId:(NSString *)groupId
               comment:(NSString *)commentString
{
    self = [super init];
    if (self) {
        self.listener = lis;
        ticketGroupId = groupId;
        comment = commentString;
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
    return @"v2/customerservice/";
}

- (NSDictionary *)createRequest
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [Utilities transitId], @"transitid",
            ticketGroupId, @"ticketgroupid",
            @"servicerequest", @"requesttype",
            [comment stringByReplacingOccurrencesOfString:@" " withString:@"%20"], @"comment",
            nil];
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    NSString *result = [json valueForKey:@"result"];
    
    if ([result isEqualToString:@"success"]) {
        return YES;
    }
    
    return NO;
}

@end
