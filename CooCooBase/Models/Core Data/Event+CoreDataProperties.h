//
//  Event+CoreDataProperties.h
//  
//
//  Created by omniwyse on 14/03/18.
//
//

#import "Event.h"


NS_ASSUME_NONNULL_BEGIN

@interface Event (CoreDataProperties)

+ (NSFetchRequest<Event *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSString *ticketid;
@property (nullable, nonatomic, copy) NSNumber *clickedTime;
@property (nullable, nonatomic, copy) NSNumber *amountRemaining;
@property (nullable, nonatomic, copy) NSNumber *fare;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *walletContentUsageIdentifier;
@property (nullable, nonatomic, copy) NSString *ticketActivationExpiryDate;

@end

NS_ASSUME_NONNULL_END
