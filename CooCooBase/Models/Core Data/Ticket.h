//
//  Ticket.h
//  CooCooBase
//
//  Created by CooCooTech on 5/15/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Ticket : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

FOUNDATION_EXPORT NSString *const TICKET_MODEL;
FOUNDATION_EXPORT NSString *const ACTIVE;
FOUNDATION_EXPORT NSString *const INACTIVE;
FOUNDATION_EXPORT NSString *const HISTORY;
FOUNDATION_EXPORT NSString *const TRANSACTIONS;
FOUNDATION_EXPORT NSString *const TICKET_IMAGES;
FOUNDATION_EXPORT NSString *const EVENT_TYPE_ACTIVATE;
FOUNDATION_EXPORT NSString *const EVENT_TYPE_REDEEM;
FOUNDATION_EXPORT NSString *const EVENT_TYPE_FLAG_TIME;
FOUNDATION_EXPORT NSString *const STATUS_ACTIVATED;
FOUNDATION_EXPORT NSString *const ACTIVATION_TYPE;
FOUNDATION_EXPORT NSString *const EXPIRED;
FOUNDATION_EXPORT NSString *const PENDING_ACTIVATION;

FOUNDATION_EXPORT double const DEFAULT_ACTIVATION_TIMESTAMP;

- (NSString *)label;
- (NSString *)stackedLabel;
- (NSString *)details;
- (NSString *)activeDetails;
- (NSString *)fullName;
- (NSString *)ticketId;
- (void)evaluateState:(NSDate *)currentDate;
- (void)setExpirationDateForTicketFromDate:(NSDate *)date usingManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

NS_ASSUME_NONNULL_END

#import "Ticket+CoreDataProperties.h"
