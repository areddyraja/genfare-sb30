//
//  LoyaltyBonus+CoreDataProperties.h
//  
//
//  Created by Ravi Jampala on 3/28/18.
//
//

#import "LoyaltyBonus.h"


NS_ASSUME_NONNULL_BEGIN

@interface LoyaltyBonus (CoreDataProperties)

+ (NSFetchRequest<LoyaltyBonus *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *activatedTime;
@property (nullable, nonatomic, copy) NSString *productId;
@property (nullable, nonatomic, copy) NSNumber *rideCount;
@property (nullable, nonatomic, copy) NSNumber *ticketId;
@property (nullable, nonatomic, copy) NSString *walletId;
@property (nullable, nonatomic, copy) NSDate *referenceActivatedTime;
@property (nullable, nonatomic, copy) NSString *productName;
@end

NS_ASSUME_NONNULL_END
