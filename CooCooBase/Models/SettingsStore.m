//
//  SettingsStore.m
//  CooCooBase
//
//  Created by CooCooTech on 7/21/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "SettingsStore.h"
#import "CooCooAccountUtilities1.h"
#import "StoredData.h"
#import "Utilities.h"

NSString *const EMAIL_PREFERENCE = @"email_preference";
NSString *const VERIFIED_PREFERENCE = @"verified_preference";
NSString *const FIRST_NAME_PREFERENCE = @"first_name_preference";
NSString *const LAST_NAME_PREFERENCE = @"last_name_preference";

@implementation SettingsStore
{
    NSManagedObjectContext *managedObjectContext;
    NSUserDefaults *defaults;
    Account *account;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    
    if (self) {
        managedObjectContext = context;
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)setObject:(id)value forKey:(NSString *)key
{
    account = [CooCooAccountUtilities1 currentAccount:managedObjectContext];
    
    if ([key isEqualToString:EMAIL_PREFERENCE]) {
        [account setEmailaddress:value];
    } else if ([key isEqualToString:VERIFIED_PREFERENCE]) {
        [account setEmailverified:[NSNumber numberWithBool:value]];
    } else if ([key isEqualToString:FIRST_NAME_PREFERENCE]) {
        [account setFirstName:value];
    } else if ([key isEqualToString:LAST_NAME_PREFERENCE]) {
        [account setLastName:value];
    } else {
        [defaults setObject:value forKey:key];
    }
}

- (id)objectForKey:(NSString *)key
{
    account = [CooCooAccountUtilities1 currentAccount:managedObjectContext];
    
    if ([key isEqualToString:EMAIL_PREFERENCE]) {
        return account.emailaddress;
    } else if ([key isEqualToString:VERIFIED_PREFERENCE]) {
        return account.emailverified ? [Utilities stringResourceForId:@"yes"] : [Utilities stringResourceForId:@"no"];
    } else if ([key isEqualToString:FIRST_NAME_PREFERENCE]) {
        return account.firstName;
    } else if ([key isEqualToString:LAST_NAME_PREFERENCE]) {
        return account.lastName;
    } else {
        return [defaults objectForKey:key];
    }
}

- (BOOL)synchronize
{
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"SettingsStore managedObjectContext error, couldn't save: %@", [error localizedDescription]);
    }
    
    return [defaults synchronize];
}

@end
