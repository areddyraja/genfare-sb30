//
//  ResendVerificationService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/30/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "ResendVerificationService.h"
#import "Utilities.h"

@implementation ResendVerificationService
{
    NSString *username;
}

- (id)initWithListener:(id)lis
              username:(NSString *)user
{
    self = [super init];
    if (self) {
        self.listener = lis;
        username = user;
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
    return @"useraccounts/regenerateAccountVerification";
}

- (NSDictionary *)createRequest
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            username, @"emailaddress",
            nil];
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        return YES;
    }
    
    return NO;
}

@end
