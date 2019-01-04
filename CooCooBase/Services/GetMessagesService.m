//
//  GetMessagesService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetMessagesService.h"
#import "Utilities.h"
#import "RuntimeData.h"

@implementation GetMessagesService

- (id)initWithListener:(id)lis
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = lis;
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
    return @"device-messages";
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
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        
        for (NSDictionary *messageJson in [json valueForKey:@"result"]) {
            NSString *message = [messageJson valueForKey:@"message"];
            
            if ([message length] > 0) {
                [messages addObject:message];
            }
        }
        
        if ([messages count] > 0) {
            [[RuntimeData instance] setAppMessages:[messages copy]];
        }
        
        return YES;
    }
    
    return NO;
}

@end
