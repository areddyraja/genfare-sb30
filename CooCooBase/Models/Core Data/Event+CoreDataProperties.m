//
//  Event+CoreDataProperties.m
//  
//
//  Created by omniwyse on 14/03/18.
//
//

#import "Event+CoreDataProperties.h"

@implementation Event (CoreDataProperties)

+ (NSFetchRequest<Event *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Event"];
}

@dynamic identifier;
@dynamic ticketid;
@dynamic clickedTime;
@dynamic amountRemaining;
@dynamic fare;
@dynamic type;
@dynamic walletContentUsageIdentifier;
@dynamic ticketActivationExpiryDate;
@end
