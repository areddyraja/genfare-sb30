//
//  LoginService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "LoginService.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"


@implementation LoginService


- (id)initWithListener:(id)lis
              username:(NSString *)user
              password:(NSString *)pass
  managedObjectContext:(NSManagedObjectContext *)context
                  uuid:(NSString *)deviceUUID
{
    self = [super init];
    if (self) {
        self.listener = lis;
        self.method = METHOD_POST;
        username = user;
        password = pass;
        self.managedObjectContext = context;
        uuid = deviceUUID;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
//    return [Utilities apiHost];
    return [Utilities dev_ApiHost];
}

- (NSString *)uri
{
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"services/data-api/mobile/login?tenant=%@",tenantId];
    //return @"services/data-api/mobile/login?tenant=COTA";
}


- (NSDictionary *)headers
{
    NSLog(@"login headers called");
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    NSString * base64String = [Utilities commonaccessToken];
    [headers setValue:[NSString stringWithFormat:@"bearer %@", base64String] forKey:@"Authorization"];
    [headers setValue:@"application/json" forKey:@"Accept"];
    return headers;
}



- (NSDictionary *)createRequest
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            username, @"emailaddress",
            password, @"password",
            uuid, @"deviceUUid",
            nil];
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        NSString *message = [json valueForKey:@"message"];
        
        if (([message length] == 0) || (([message length] > 0) && [message caseInsensitiveCompare:@"pending"] != NSOrderedSame)) {
            NSArray *data = [json valueForKeyPath:@"result"];
            
            if (data != nil) {
                NSString *accountId = [data valueForKey:@"accountid"];
                
                [CooCooAccountUtilities1 deleteAccountIfIdExists:accountId managedObjectContext:self.managedObjectContext];
                
                NSString *authToken = [data valueForKey:@"authtoken"];
                
                //                if ([authToken length] > 0) {
                // Only one account should be logged in at any given time
                [CooCooAccountUtilities1 logoutAllAccounts:self.managedObjectContext];
                
                Account *account = (Account *)[NSEntityDescription insertNewObjectForEntityForName:ACCOUNT_MODEL
                                                                            inManagedObjectContext:self.managedObjectContext];
                [account setAccountId:[data valueForKey:@"accountid"]];
                [account setActive:[data valueForKey:@"active"]];
                [account setCreated:[data valueForKey:@"created"]];
                [account setEmailaddress:[data valueForKey:@"emailaddress"]];
                [account setPassword:password];
                [account setEmailverified:[NSNumber numberWithBool:([[data valueForKey:@"emailverified"] isEqualToString:@"yes"])]];
                //                    NSMutableArray * fareCodeArray = [[NSMutableArray alloc]init];
                //                    fareCodeArray = [[data valueForKey:@"farecode"] mutableCopy];
                //                    [account setFarecode:fareCodeArray];
                [account setFirstName:[data valueForKey:@"firstname"]];
                [account setId:[data valueForKey:@"id"]];
                [account setLastlogin:[data valueForKey:@"lastlogin"]];
                [account setLastName:[data valueForKey:@"lastname"]];
                [account setLastupdated:[data valueForKey:@"lastupdated"]];
                [account setMobilenumber:[data valueForKey:@"mobilenumber"]];
                [account setMobileverified:[data valueForKey:@"mobileverified"]];
                [account setNotes:[data valueForKey:@"notes"]];
                [account setStatus:[data valueForKey:@"status"]];
                [account setTokengenerated:[data valueForKey:@"tokengenerated"]];
                [account setIsLoggedIn:[NSNumber numberWithBool:YES]];
                [account setLoginDateTime:[NSDate date]];
                [account setProfileType:[data valueForKey:@"profiletype"]];
                 [account setNeeds_additional_auth:[[data valueForKey:@"needs_additional_auth"]boolValue]];
                NSError *error;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
                    
                    return NO;
                }
                return YES;
                //                }
            }
        }
    }
    
    return NO;
}

@end

