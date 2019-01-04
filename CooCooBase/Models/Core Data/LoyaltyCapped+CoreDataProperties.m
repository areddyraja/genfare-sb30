//
//  LoyaltyCapped+CoreDataProperties.m
//  
//
//  Created by Ravi Jampala on 3/28/18.
//
//

#import "LoyaltyCapped+CoreDataProperties.h"

@implementation LoyaltyCapped (CoreDataProperties)

+ (NSFetchRequest<LoyaltyCapped *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"LoyaltyCapped"];
}

@dynamic rideCount;
@dynamic ticketId;
@dynamic activatedTime;
@dynamic walletId;
@dynamic productId;
@dynamic referenceActivatedTime;
@dynamic productName;
@end
