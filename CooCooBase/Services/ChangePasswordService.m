//
//  ChangePasswordService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "ChangePasswordService.h"
#import <UIKit/UIKit.h>
#import "StoredData.h"
#import "Utilities.h"

@implementation ChangePasswordService
{

    NSString *email;
    NSString *oldPassword;
    NSString *password;
}

- (id)initWithListener:(id)lis
                 email:(NSString *)mail
              password:(NSString *)pass oldpassword:(NSString *)oldpass

{
    self = [super init];
    if (self) {
        self.listener = lis;
        email = mail;
        password = pass;
        oldPassword = oldpass;
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
    NSString * updatedUri = [NSString stringWithFormat:@"/services/data-api/mobile/users/changepassword?tenant=%@",tenantId];
    return updatedUri;
    //return @"/services/data-api/mobile/users/changepassword?tenant=COTA";
}

- (NSDictionary *)createRequest
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            email, @"emailaddress",
            password, @"new_password",
            oldPassword,@"old_password",
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
