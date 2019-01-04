//
//  Card+CoreDataProperties.h
//  CooCooBase
//
//  Created by CooCooTech on 4/1/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Card.h"

NS_ASSUME_NONNULL_BEGIN

@interface Card (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accountAuthToken;
@property (nullable, nonatomic, retain) NSString *accountEmail;
@property (nullable, nonatomic, retain) NSString *cardDescription;
@property (nullable, nonatomic, retain) NSDate *createdDateTime;
@property (nullable, nonatomic, retain) NSString *cvv;
@property (nullable, nonatomic, retain) NSString *huuid;
@property (nullable, nonatomic, retain) NSNumber *isTemporary;
@property (nullable, nonatomic, retain) NSDate *modifiedDateTime;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSString *walletHuuid;

@property (nullable, nonatomic, retain) NSNumber *walletId;
@property (nullable, nonatomic, retain) NSString *walletUuid;
@property (nullable, nonatomic, retain) NSNumber *accountId;
@property (nullable, nonatomic, retain) NSString *nickname;
@property (nullable, nonatomic, retain) NSString *uuid;






@end

NS_ASSUME_NONNULL_END
