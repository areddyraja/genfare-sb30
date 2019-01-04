//
//  WalletContents+CoreDataProperties.h
//  
//
//  Created by Omniwyse on 3/6/18.
//
//

#import "WalletContents.h"


NS_ASSUME_NONNULL_BEGIN

@interface WalletContents (CoreDataProperties)

+ (NSFetchRequest<WalletContents *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *agencyId;
@property (nullable, nonatomic, copy) NSNumber *allowInteraction;
@property (nullable, nonatomic, copy) NSString *balance;
@property (nullable, nonatomic, copy) NSString *descriptation;
@property (nullable, nonatomic, copy) NSNumber *designator;
@property (nullable, nonatomic, copy) NSNumber *fare;
@property (nullable, nonatomic, copy) NSString *group;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSNumber *instanceCount;
@property (nullable, nonatomic, copy) NSString *member;
@property (nullable, nonatomic, copy) NSNumber *purchasedDate;
@property (nullable, nonatomic, copy) NSString *expirationDate;
@property (nullable, nonatomic, copy) NSNumber *slot;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSNumber *ticketActivationExpiryDate;
@property (nullable, nonatomic, copy) NSNumber *ticketEffectiveDate;
@property (nullable, nonatomic, copy) NSNumber *ticketExpiryDate;
@property (nullable, nonatomic, copy) NSString *ticketGroup;
@property (nullable, nonatomic, copy) NSString *ticketIdentifier;
@property (nullable, nonatomic, copy) NSString *ticketSource;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSNumber *valueOriginal;
@property (nullable, nonatomic, copy) NSNumber *valueRemaining;
@property (nullable, nonatomic, copy) NSNumber *activationCount;
@property (nullable, nonatomic, copy) NSNumber *activationDate;
@property (nullable, nonatomic, copy) NSNumber *generationDate;
@property (nullable, nonatomic, copy) NSNumber *farecodeExpiryDateTime;

@end

NS_ASSUME_NONNULL_END
