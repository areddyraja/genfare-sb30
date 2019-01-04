//
//  CooCooAccountUtilities1.h
//  CooCooBase
//
//  Created by CooCooTech on 9/21/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Account.h"

@interface CooCooAccountUtilities1 : NSObject

+ (NSArray *)allAccounts:(NSManagedObjectContext *)managedObjectContext;
+ (Account *)currentAccount:(NSManagedObjectContext *)managedObjectContext;
+ (void)setCurrentAccount:(NSString *)accountId managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (Account *)loggedInAccount:(NSManagedObjectContext *)managedObjectContext;
+ (void)deleteAccountIfIdExists:(NSString *)accountId managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)logoutAllAccounts:(NSManagedObjectContext *)managedObjectContext;

@end
