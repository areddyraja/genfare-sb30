//
//  UserData.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "UserData.h"

NSString *const KEY_ACCOUNT_ID = @"accountId";
NSString *const PASSWORD = @"password";
NSString *const KEY_AUTH_TOKEN = @"authToken";
NSString *const KEY_EMAIL = @"email";
NSString *const KEY_EMAIL_VERIFIED = @"emailVerified";
NSString *const KEY_FIRST_NAME = @"firstName";
NSString *const KEY_LAST_NAME = @"lastName";
NSString *const KEY_LOGGED_IN = @"loggedIn";
NSString *const KEY_LOGGED_IN_DATE_TIME = @"loggedInDateTime";

@implementation UserData

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.accountId = [decoder decodeObjectForKey:KEY_ACCOUNT_ID];
        self.password = [decoder decodeObjectForKey:PASSWORD];
        self.authToken = [decoder decodeObjectForKey:KEY_AUTH_TOKEN];
        self.email = [decoder decodeObjectForKey:KEY_EMAIL];
        self.emailVerified = [decoder decodeBoolForKey:KEY_EMAIL_VERIFIED];
        self.firstName = [decoder decodeObjectForKey:KEY_FIRST_NAME];
        self.lastName = [decoder decodeObjectForKey:KEY_LAST_NAME];
        self.loggedIn = [decoder decodeBoolForKey:KEY_LOGGED_IN];
        self.loggedInDateTime = [decoder decodeObjectForKey:KEY_LOGGED_IN_DATE_TIME];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.accountId forKey:KEY_ACCOUNT_ID];
    [encoder encodeObject:self.password forKey:PASSWORD];
    [encoder encodeObject:self.authToken forKey:KEY_AUTH_TOKEN];
    [encoder encodeObject:self.email forKey:KEY_EMAIL];
    [encoder encodeBool:self.emailVerified forKey:KEY_EMAIL_VERIFIED];
    [encoder encodeObject:self.firstName forKey:KEY_FIRST_NAME];
    [encoder encodeObject:self.lastName forKey:KEY_LAST_NAME];
    [encoder encodeBool:self.loggedIn forKey:KEY_LOGGED_IN];
    [encoder encodeObject:self.loggedInDateTime forKey:KEY_LOGGED_IN_DATE_TIME];
}

@end
