//
//  StoredValueLoyalty+CoreDataProperties.h
//  CDTATicketing
//
//  Created by CooCooTech on 5/11/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StoredValueLoyalty.h"

NS_ASSUME_NONNULL_BEGIN

@interface StoredValueLoyalty (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *activationCount;
@property (nullable, nonatomic, retain) NSNumber *bonusAmount;
@property (nullable, nonatomic, retain) NSDate *createdDateTime;
@property (nullable, nonatomic, retain) NSDate *expirationDateTime;
@property (nullable, nonatomic, retain) NSDate *modifiedDateTime;
@property (nullable, nonatomic, retain) NSString *productCode;
@property (nullable, nonatomic, retain) NSNumber *requirementMagnitude;
@property (nullable, nonatomic, retain) NSNumber *riderCount;
@property (nullable, nonatomic, retain) NSString *cardUuid;

@end

NS_ASSUME_NONNULL_END
