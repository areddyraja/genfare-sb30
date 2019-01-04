//
//  TicketActivation+CoreDataProperties.h
//  
//
//  Created by omniwyse on 09/03/18.
//
//

#import "TicketActivation.h"


NS_ASSUME_NONNULL_BEGIN

@interface TicketActivation (CoreDataProperties)
@property (nullable, nonatomic, copy) NSString *activationDate;
@property (nullable, nonatomic, copy) NSString *activationExpDate;
@property (nullable, nonatomic, copy) NSString *ticketIdentifier;

@end

NS_ASSUME_NONNULL_END
