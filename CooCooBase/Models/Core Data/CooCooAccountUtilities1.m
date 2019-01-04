//
//  AccountUtilities.m
//  CooCooBase
//
//  Created by CooCooTech on 9/21/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CooCooAccountUtilities1.h"

@implementation CooCooAccountUtilities1

+ (NSArray *)allAccounts:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ACCOUNT_MODEL
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *accounts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return accounts;
}

/*
 * There should only ever be one current account, return nil otherwise
 */
+ (Account *)currentAccount:(NSManagedObjectContext *)managedObjectContext;

{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ACCOUNT_MODEL
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCurrent == 1"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLoggedIn == 1"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *accounts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([accounts count] == 1) {
        return [accounts objectAtIndex:0];
    } else if ([accounts count] == 0) {
        // If LoginService is called for an account marked as "current", it will delete the object, so re-set it as "current"
        Account *loggedInAccount = [self loggedInAccount:managedObjectContext];
        
        [self setCurrentAccount:loggedInAccount.accountId managedObjectContext:managedObjectContext];
        
        // Re-run the fetch logic
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:ACCOUNT_MODEL
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCurrent == 1"];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *accounts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([accounts count] == 1) {
            return [accounts objectAtIndex:0];
        }
    }
    
    return nil;
}

+ (void)setCurrentAccount:(NSString *)accountId managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
    // First de-select any account that is already set as "current"
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ACCOUNT_MODEL
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCurrent == 1"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *accounts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Account *account in accounts) {
        [account setIsCurrent:[NSNumber numberWithBool:NO]];
    }
    
    // Set account with given accountId as "current"
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:ACCOUNT_MODEL
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    predicate = [NSPredicate predicateWithFormat:@"accountId == %@", accountId];
    [fetchRequest setPredicate:predicate];
    
    accounts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([accounts count] == 1) {
        Account *currentAccount = [accounts objectAtIndex:0];
        [currentAccount setIsCurrent:[NSNumber numberWithBool:YES]];
    }
    
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
}

/*
 * There should only ever be one logged in account, return nil otherwise
 */
+ (Account *)loggedInAccount:(NSManagedObjectContext *)managedObjectContext;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ACCOUNT_MODEL
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLoggedIn == 1"];
    //[fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *accounts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    //NSArray *acc = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    if ([accounts count] >= 1) {
        return [accounts objectAtIndex:0];
    }
    
    return nil;
}

/*
 * Delete local data of account so it can be replaced with the latest data from API
 */
+ (void)deleteAccountIfIdExists:(NSString *)accountId managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ACCOUNT_MODEL
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountId == %@", accountId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *accounts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Account *account in accounts) {
        [managedObjectContext deleteObject:account];
    }
    
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
}

+ (void)logoutAllAccounts:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ACCOUNT_MODEL
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLoggedIn == 1"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *accounts = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Account *account in accounts) {
        [account setIsLoggedIn:[NSNumber numberWithBool:NO]];
    }
    
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
}

@end
