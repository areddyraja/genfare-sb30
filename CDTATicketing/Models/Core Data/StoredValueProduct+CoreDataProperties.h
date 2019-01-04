//
//  StoredValueProduct+CoreDataProperties.h
//  CDTATicketing
//
//  Created by CooCooTech on 3/28/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StoredValueProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface StoredValueProduct (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *amount;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSData *entrants;
@property (nullable, nonatomic, retain) NSString *memberId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *note;
@property (nullable, nonatomic, retain) NSString *productDescription;
@property (nullable, nonatomic, retain) NSNumber *productId;
@property (nullable, nonatomic, retain) NSNumber *revisionId;
@property (nullable, nonatomic, retain) NSData *tenant;
@property (nullable, nonatomic, retain) NSString *ticketGroupId;
@property (nullable, nonatomic, retain) NSData *ticketSettings;
@property (nullable, nonatomic, retain) NSNumber *isForSale;
@property (nullable, nonatomic, retain) NSSet<StoredValueLoyalty *> *partOfLoyalty;

@end

@interface StoredValueProduct (CoreDataGeneratedAccessors)

- (void)addPartOfLoyaltyObject:(StoredValueLoyalty *)value;
- (void)removePartOfLoyaltyObject:(StoredValueLoyalty *)value;
- (void)addPartOfLoyalty:(NSSet<StoredValueLoyalty *> *)values;
- (void)removePartOfLoyalty:(NSSet<StoredValueLoyalty *> *)values;

@end

NS_ASSUME_NONNULL_END
