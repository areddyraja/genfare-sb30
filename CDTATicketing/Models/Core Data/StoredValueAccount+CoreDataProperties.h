//
//  StoredValueAccount+CoreDataProperties.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/7/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StoredValueAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface StoredValueAccount (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *accountId;
@property (nullable, nonatomic, retain) NSNumber *amount;
@property (nullable, nonatomic, retain) NSString *association;
@property (nullable, nonatomic, retain) NSDate *createdDateTime;
@property (nullable, nonatomic, retain) NSDate *modifiedDateTime;
@property (nullable, nonatomic, retain) NSString *nickname;
@property (nullable, nonatomic, retain) NSString *owner;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSData *tenant;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *events;

@end

@interface StoredValueAccount (CoreDataGeneratedAccessors)

- (void)addEventsObject:(NSManagedObject *)value;
- (void)removeEventsObject:(NSManagedObject *)value;
- (void)addEvents:(NSSet<NSManagedObject *> *)values;
- (void)removeEvents:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
