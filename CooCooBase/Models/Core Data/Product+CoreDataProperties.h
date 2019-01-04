//
//  Product+CoreDataProperties.h
//  CooCooBase
//
//  Created by IBase Software on 28/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "Product.h"
NS_ASSUME_NONNULL_BEGIN
@interface Product (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString* price;
@property (nullable, nonatomic, retain) NSString* productId;
@property (nullable, nonatomic, retain) NSNumber *offeringId;
@property (nullable, nonatomic, retain) NSNumber *displayOrder;
@property (nullable, nonatomic, retain) NSNumber *barcodeTimer;
@property (nullable, nonatomic, retain) NSNumber *cappedThreshold;
@property (nullable, nonatomic, retain) NSNumber *bonusThreshold;
@property (nullable, nonatomic ,retain) NSNumber *ticketId;
@property (nullable, nonatomic, retain) NSString *productDescription;
@property (nullable, nonatomic, retain) NSString *designator;
@property (nullable, nonatomic, retain) NSString *ticketTypeId;
@property (nullable, nonatomic, retain) NSString *ticketSubTypeId;
@property (nullable, nonatomic, retain) NSString *fareCode;
@property (nullable, nonatomic, retain) NSNumber *isActivationOnly;
@property (nullable, nonatomic, retain) NSString *ticketTypeDescription;
@property (nullable, nonatomic, retain) NSNumber *isBonusRideEnabled;
@property (nullable, nonatomic, retain) NSNumber *isCappedRideEnabled;
@end
NS_ASSUME_NONNULL_END
