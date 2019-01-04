//
//  LoyaltyBonus+CoreDataProperties.m
//  
//
//  Created by Ravi Jampala on 3/28/18.
//
//

#import "LoyaltyBonus+CoreDataProperties.h"

@implementation LoyaltyBonus (CoreDataProperties)

+ (NSFetchRequest<LoyaltyBonus *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"LoyaltyBonus"];
}

@dynamic activatedTime;
@dynamic productId;
@dynamic rideCount;
@dynamic ticketId;
@dynamic walletId;
@dynamic referenceActivatedTime;
@dynamic productName;
@end
