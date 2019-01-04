//
//  ChangeEmailService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "ChangeEmailService.h"
#import "CooCooAccountUtilities1.h"
#import "Utilities.h"

@implementation ChangeEmailService
{
    NSString *accountid;
    NSString *password;
    NSString *firstName;
    NSString *lastName;
    NSString *existingEmail;
    NSDictionary *farecode;
}

- (id)initWithListener:(id)lis
             accountid:(NSString *)newEmail
              password:(NSString *)pass
             firstName:(NSString *)fName
              lastName:(NSString *)lName
         existingEmail:(NSString *)exEmail
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        accountid = newEmail;
        password = pass;
        firstName = fName;
        lastName = lName;
        existingEmail = exEmail;
        self.method = METHOD_PUT;
        self.listener = lis;
        self.managedObjectContext = context;
        
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
    NSString * updatedUri = [NSString stringWithFormat:@"services/data-api/mobile/users/%@?tenant=%@",existingEmail,tenantId];
        return updatedUri;
}

- (NSDictionary *)createRequest
{
    farecode = @"FULL";
    NSLog(@"AuthorizeTokenService request: %@", [NSDictionary dictionaryWithObjectsAndKeys:
                                                 accountid, @"id",
                                                 password, @"password",
                                                 firstName, @"firstName",
                                                 lastName, @"lastName",nil]);
    return [NSDictionary dictionaryWithObjectsAndKeys:
            accountid, @"id",
            password, @"password",
            firstName, @"firstName",
            lastName, @"lastName",
            nil];
  
}
- (BOOL)processResponse:(id)serverResult
{
    NSLog(@"changeemail result: %@", serverResult);
    return YES;
}

//- (BOOL)processResponse:(id)serverResult
//{
//       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    //json = [json dictionaryRemovingNSNullValues];
//
//    if ([BaseService isResponseOk:json]) {
//        NSArray *data = [json valueForKeyPath:@"result"];
//
//        if (data != nil) {
//            NSString *accountId = [data valueForKey:@"accountid"];
//
//            [CooCooAccountUtilities1 deleteAccountIfIdExists:accountId managedObjectContext:self.managedObjectContext];
//
//            NSString *authToken = [data valueForKey:@"authtoken"];
//
//            if ([authToken length] > 0) {
//                Account *account = (Account *)[NSEntityDescription insertNewObjectForEntityForName:ACCOUNT_MODEL
//                                                                            inManagedObjectContext:self.managedObjectContext];
//                [account setAuthToken:authToken];
//                [account setAccountId:[data valueForKey:@"accountid"]];
//                [account setEmailaddress:[data valueForKey:@"emailaddress"]];
//                [account setFirstName:[data valueForKey:@"firstname"]];
//                [account setLastName:[data valueForKey:@"lastname"]];
//                [account setEmailverified:[NSNumber numberWithBool:([[data valueForKey:@"emailverified"] isEqualToString:@"yes"])]];
//                [account setIsLoggedIn:[NSNumber numberWithBool:YES]];
//                [account setLoginDateTime:[NSDate date]];
//
//                NSError *error;
//                if (![self.managedObjectContext save:&error]) {
//                    NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
//
//                    return NO;
//                }
//
//                return YES;
//            }
//        }
//    }
//
//    return NO;
//}

@end

