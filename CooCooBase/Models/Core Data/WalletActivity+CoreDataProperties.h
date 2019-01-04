//
//  WalletContents+CoreDtaProperties.h
//  CooCooBase
//
//  Created by IBase Software on 29/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "WalletActivity.h"
NS_ASSUME_NONNULL_BEGIN

@interface WalletActivity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *event;
@property (nullable, nonatomic, retain) NSNumber *activityId;
@property (nullable, nonatomic, retain) NSNumber *activityTypeId;
@property (nullable, nonatomic, retain) NSNumber *amountCharged;
@property (nullable, nonatomic, retain) NSNumber *amountRemaining;
@property (nullable, nonatomic, retain) NSNumber *date;
@property (nullable, nonatomic, retain) NSNumber *ticketId;





@end
NS_ASSUME_NONNULL_END
