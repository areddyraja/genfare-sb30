//
//  Wallet+CoreDataProperties.h
//  CooCooBase
//
//  Created by CooCooTech on 4/15/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Wallet.h"

NS_ASSUME_NONNULL_BEGIN

@interface Wallet (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *deviceUUID;
@property (nullable, nonatomic, retain) NSString *nickname;
@property (nullable, nonatomic, retain) NSString *status;
@property (nullable, nonatomic, retain) NSNumber *personId;
@property (nullable, nonatomic, retain) NSNumber *statusId;
@property (nullable, nonatomic, retain) NSString *walletUUID;
@property (nullable, nonatomic, retain) NSString *accountType;
@property (nullable, nonatomic, retain) NSString *cardType;
@property (nullable, nonatomic, retain) NSNumber *farecodeExpiryDateTime;

@end

NS_ASSUME_NONNULL_END
