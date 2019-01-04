//
//  UserData.h
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserData : NSObject

@property (copy, nonatomic) NSNumber *accountId;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *authToken;
@property (copy, nonatomic) NSString *email;
@property (nonatomic, getter = isEmailVerified) BOOL emailVerified;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (nonatomic, getter = isLoggedIn) BOOL loggedIn;
@property (copy, nonatomic) NSDate *loggedInDateTime;

@end
