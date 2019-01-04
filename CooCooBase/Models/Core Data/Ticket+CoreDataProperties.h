//
//  Ticket+CoreDataProperties.h
//  CooCooBase
//
//  Created by CooCooTech on 5/15/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Ticket.h"

NS_ASSUME_NONNULL_BEGIN

@interface Ticket (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *activatedSeconds;
@property (nullable, nonatomic, retain) NSNumber *activationCount;
@property (nullable, nonatomic, retain) NSNumber *activationCountMax;
@property (nullable, nonatomic, retain) NSNumber *activationDateTime;
@property (nullable, nonatomic, retain) NSNumber *activationLiveTime;
@property (nullable, nonatomic, retain) NSNumber *activationResetTime;
@property (nullable, nonatomic, retain) NSNumber *activationTransitionTime;
@property (nullable, nonatomic, retain) NSString *activationType;
@property (nullable, nonatomic, retain) NSNumber *arrivalStation;
@property (nullable, nonatomic, retain) NSString *arriveId;
@property (nullable, nonatomic, retain) NSString *arriveStationId;
@property (nullable, nonatomic, retain) NSString *bfp;
@property (nullable, nonatomic, retain) NSString *creditCard;
@property (nullable, nonatomic, retain) NSString *departId;
@property (nullable, nonatomic, retain) NSString *departStationId;
@property (nullable, nonatomic, retain) NSNumber *departureStation;
@property (nullable, nonatomic, retain) NSString *deviceId;
@property (nullable, nonatomic, retain) NSNumber *eventLat;
@property (nullable, nonatomic, retain) NSNumber *eventLng;
@property (nullable, nonatomic, retain) NSString *eventType;
@property (nullable, nonatomic, retain) NSNumber *expirationDateTime;
@property (nullable, nonatomic, retain) NSNumber *expirationSpan;
@property (nullable, nonatomic, retain) NSString *fareCode;
@property (nullable, nonatomic, retain) NSString *fareZoneCode;
@property (nullable, nonatomic, retain) NSString *fareZoneCodeDesc;
@property (nullable, nonatomic, retain) NSNumber *firstActivationDateTime;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSNumber *inspections;
@property (nullable, nonatomic, retain) NSString *invoiceId;
@property (nullable, nonatomic, retain) NSNumber *isAdjustedForDst;
@property (nullable, nonatomic, retain) NSNumber *isHistory;
@property (nullable, nonatomic, retain) NSNumber *isStoredValue;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSNumber *lastUpdated;
@property (nullable, nonatomic, retain) NSString *memberId;
@property (nullable, nonatomic, retain) NSNumber *purchaseDateTime;
@property (nullable, nonatomic, retain) NSNumber *riderCount;
@property (nullable, nonatomic, retain) NSString *riderTypeCode;
@property (nullable, nonatomic, retain) NSString *riderTypeDesc;
@property (nullable, nonatomic, retain) NSString *sellerId;
@property (nullable, nonatomic, retain) NSString *serviceCode;
@property (nullable, nonatomic, retain) NSString *status;
@property (nullable, nonatomic, retain) NSNumber *statusCode;
@property (nullable, nonatomic, retain) NSString *szType;
@property (nullable, nonatomic, retain) NSNumber *ticketAmount;
@property (nullable, nonatomic, retain) NSString *ticketGroupId;
@property (nullable, nonatomic, retain) NSString *ticketTypeCode;
@property (nullable, nonatomic, retain) NSString *ticketTypeDesc;
@property (nullable, nonatomic, retain) NSString *ticketTypeNote;
@property (nullable, nonatomic, retain) NSString *transitId;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSNumber *validStartDateTime;
@property (nullable, nonatomic, retain) NSNumber *isStaging;
@property (nullable, nonatomic, retain) NSNumber *isCurrent;

@end

NS_ASSUME_NONNULL_END
