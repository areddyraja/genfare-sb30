
//
//  RegisterAccountService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "RegisterAccountService.h"
#import <UIKit/UIKit.h>
#import "StoredData.h"
#import "Utilities.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"


@implementation RegisterAccountService
{
    NSString *username;
    NSString *password;
    NSString *firstName;
    NSString *lastName;
 }

- (id)initWithListener:(id)lis
              username:(NSString *)user
              password:(NSString *)pass
             firstName:(NSString *)first
              lastName:(NSString *)last
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.listener = lis;
        username = user;
        password = pass;
        firstName = first;
        lastName = last;
        self.managedObjectContext = context;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
   // return [Utilities apiHost];
    return [Utilities dev_ApiHost];
}

- (NSString *)uri
{
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"services/data-api/mobile/users?tenant=%@",tenantId];
    //return @"services/data-api/mobile/users?tenant=COTA";
   
}

- (NSDictionary *)createRequest
{
    NSLog(@"json req: %@", [NSDictionary dictionaryWithObjectsAndKeys:
                            username, @"emailaddress",
                            password, @"password",
                            firstName, @"firstname",
                            lastName, @"lastname",
                            nil]);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            username, @"emailaddress",
            password, @"password",
            firstName, @"firstname",
            lastName, @"lastname",
            nil];
}

- (BOOL)processResponse:(id)serverResult{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        NSArray *data = [json valueForKeyPath:@"result"];
        
        if (data != nil) {
            UserData *userData = [StoredData userData];
            
            [userData setAccountId:[data valueForKey:@"accountid"]];
            [userData setAuthToken:[data valueForKey:@"authtoken"]];
            [userData setEmail:[data valueForKey:@"emailaddress"]];
            [userData setFirstName:[data valueForKey:@"firstname"]];
            [userData setLastName:[data valueForKey:@"lastname"]];
            [userData setLoggedIn:YES];
            
            NSString *emailVerified = [data valueForKey:@"emailverified"];
            
            if ([emailVerified caseInsensitiveCompare:@"yes"] == NSOrderedSame) {
                [userData setEmailVerified:YES];
            } else {
                [userData setEmailVerified:NO];
            }
            
            [StoredData commitUserDataWithData:userData];
            //             return YES;
            
            NSString *message = [json valueForKey:@"message"];
            
            if (([message length] == 0) || (([message length] > 0) && [message caseInsensitiveCompare:@"pending"] != NSOrderedSame)) {
                NSArray *data = [json valueForKeyPath:@"result"];
                
                if (data != nil) {
                    NSString *accountId = [data valueForKey:@"accountid"];
                    
                    [CooCooAccountUtilities1 deleteAccountIfIdExists:accountId managedObjectContext:self.managedObjectContext];
                    
                    NSString *authToken = [data valueForKey:@"authtoken"];
                    
                    //                        if ([authToken length] > 0) {
                    // Only one account should be logged in at any given time
                    [CooCooAccountUtilities1 logoutAllAccounts:self.managedObjectContext];
                    
                    Account *account = (Account *)[NSEntityDescription insertNewObjectForEntityForName:ACCOUNT_MODEL
                                                                                inManagedObjectContext:self.managedObjectContext];
                    [account setAuthToken:authToken];
                    [account setAccountId:[data valueForKey:@"accountid"]];
                    [account setEmailaddress:[data valueForKey:@"emailaddress"]];
                    [account setPassword:password];
                    [account setEmailverified:[NSNumber numberWithBool:([[data valueForKey:@"emailverified"] isEqualToString:@"yes"])]];
                    [account setFirstName:[data valueForKey:@"firstname"]];
                    [account setId:[data valueForKey:@"id"]];
                    [account setLastName:[data valueForKey:@"lastname"]];
                    [account setMobilenumber:[data valueForKey:@"mobilenumber"]];
                    [account setMobileverified:[data valueForKey:@"mobileverified"]];
                    [account setNotes:[data valueForKey:@"notes"]];
                    [account setStatus:[data valueForKey:@"status"]];
                    [account setTokengenerated:[data valueForKey:@"tokengenerated"]];
                    [account setIsLoggedIn:[NSNumber numberWithBool:YES]];
                    [account setLoginDateTime:[NSDate date]];
                    [account setProfileType:[data valueForKey:@"profiletype"]];

                    NSError *error;
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
                        return NO;
                    }
                    
                    return YES;
                    //                        }
                }
            }
        }
        
        //return YES;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]message:[Utilities stringResourceForId:@"authentication_fail"]delegate:nil
          cancelButtonTitle:[Utilities stringResourceForId:@"close"]otherButtonTitles:nil];
        [alertView show];
    }
    
    return NO;
}

@end

