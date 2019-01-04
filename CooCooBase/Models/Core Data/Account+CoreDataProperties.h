//
//  Account+CoreDataProperties.h
//  CooCooBase
//
//  Created by Alfonso Cejudo on 10/7/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface Account (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *accountId;
@property (nullable, nonatomic, retain) NSString *active;
@property (nullable, nonatomic, retain) NSString *authToken;
@property (nullable, nonatomic, retain) NSString *emailaddress;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSNumber *emailverified;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSArray *farecode;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *mobilenumber;
@property (nullable, nonatomic, retain) NSString *mobileverified;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSString *status;
@property (nullable, nonatomic, retain) NSString *profileType;
@property (nullable, nonatomic, retain) NSString *tokengenerated;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSNumber *isCurrent;
@property (nullable, nonatomic, retain) NSNumber *isLoggedIn;
@property (nullable, nonatomic, retain) NSDate *loginDateTime;
@property (nullable, nonatomic, retain) NSString *created;
@property (nullable, nonatomic, retain) NSString *lastlogin;
@property (nullable, nonatomic, retain) NSString *lastupdated;
@property (nullable, nonatomic, retain) NSString *walletname;
@property (nonatomic, readwrite) BOOL needs_additional_auth;









@end

NS_ASSUME_NONNULL_END

