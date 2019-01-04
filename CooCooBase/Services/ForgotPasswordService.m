//
//  ForgotPasswordService.m
//  CooCooBase
//
//  Created by John Scuteri on 5/30/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "ForgotPasswordService.h"
#import "NSBundle+BaseResourcesBundle.h"
#import "Utilities.h"

@implementation ForgotPasswordService
{
    NSString *userEmail;
}

- (id)initWithListener:(id)lis userEmail:(NSString *)userEmailAdd
{
    self = [super init];
    if (self) {
        self.listener = lis;
        userEmail = userEmailAdd;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host{
    return [Utilities dev_ApiHost];
}

- (NSString *)uri{
    NSString *tenantId = [Utilities tenantId];
    NSString * updatedUri = [NSString stringWithFormat:@"services/data-api/mobile/users/%@/password/forgot?tenant=%@",userEmail,tenantId];
    return updatedUri;
}

- (NSDictionary *)createRequest{
    NSString *link = [Utilities stringInfoForId:@"forgot_pass_link"];
    NSString *resetUrl = [NSString stringWithFormat:@"%@/user/password-reset/confirm/", link];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            userEmail, @"emailaddress",
            @"true", @"notify",
            resetUrl, @"reseturl",
            nil];
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
//    if ([BaseService isResponseOk:json]) {
    if ((json != nil) && [json count] > 0) {
        return YES;
    }
    
    return NO;
}

@end

