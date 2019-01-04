//
//  WalletContents+CoreDataProperties.m
//  
//
//  Created by Omniwyse on 3/6/18.
//
//

#import "WalletContents+CoreDataProperties.h"

@implementation WalletContents (CoreDataProperties)

+ (NSFetchRequest<WalletContents *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WalletContents"];
}

@dynamic agencyId;
@dynamic allowInteraction;
@dynamic balance;
@dynamic descriptation;
@dynamic designator;
@dynamic fare;
@dynamic group;
@dynamic identifier;
@dynamic instanceCount;
@dynamic member;
@dynamic purchasedDate;
@dynamic expirationDate;
@dynamic slot;
@dynamic status;
@dynamic ticketActivationExpiryDate;
@dynamic ticketEffectiveDate;
@dynamic ticketExpiryDate;
@dynamic ticketGroup;
@dynamic ticketIdentifier;
@dynamic type;
@dynamic valueOriginal;
@dynamic valueRemaining;
@dynamic activationCount;
@dynamic ticketSource;
@dynamic farecodeExpiryDateTime;

@end
