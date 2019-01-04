//
//  Ticket.m
//  CooCooBase
//
//  Created by CooCooTech on 5/15/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "Ticket.h"
#import "AppConstants.h"
#import "ServiceDay.h"
#import "Utilities.h"

NSString *const TICKET_MODEL = @"Ticket";
NSString *const ACTIVE = @"active";
 NSString *const INACTIVE = @"inactive";
NSString *const HISTORY = @"history";
NSString *const TRANSACTIONS = @"transactions";
NSString *const TICKET_IMAGES = @"ticketimages";
NSString *const EVENT_TYPE_ACTIVATE = @"activate";
NSString *const EVENT_TYPE_REDEEM = @"REDEEM";
NSString *const EVENT_TYPE_FLAG_TIME = @"flag_time";
NSString *const STATUS_ACTIVATED = @"Activated";
NSString *const ACTIVATION_TYPE = @"App";
NSString *const EXPIRED = @"expired";
NSString *const PENDING_ACTIVATION = @"pending_activation";

double const DEFAULT_ACTIVATION_TIMESTAMP = 946684800;

// Private
NSString *const PURCHASE_DATE = @"\nPurchase Date: ";

@implementation Ticket

// Insert code here to add functionality to your managed object subclass


/**
 * Creates the textual information that is displayed on the Ticket's barcode, status, history and
 * Wallet list views. For the barcode and status pages this is done in an intermediary step by calling
 * the details function.
 * Whether or not the Fare Zone Description text should be displayed is controlled from the features file.
 * @return The text to be displayed, e.g.<br>
 *      "Fare Zone Description<br>
 *      Ticket Type Description<br>
 *      Rider Type Description - $1.42"
 */
- (NSString *)label
{
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setMaximumFractionDigits:2];

    NSMutableString *label = [[NSMutableString alloc]init];

    if ([Utilities featuresFromId:@"display_fare_zone_desc"] && ([self.fareZoneCodeDesc length] > 0)) {
        [label appendString:self.fareZoneCodeDesc];
    }
    if ([self.ticketTypeDesc length] > 0) {
        if ([label length] > 0)
        {
            [label appendString:@"\n"];
        }
        [label appendString:self.ticketTypeDesc];
    }
    if ([self.riderTypeDesc length] > 0) {
        if ([label length] > 0)
        {
            [label appendString:@"\n"];
        }
        [label appendString:self.riderTypeDesc];
    }
    if ([label length] > 0)
    {
        [label appendString:@" - "];
    }
    [label appendString:@"$"];
    [label appendString:[numberFormatter stringFromNumber:self.ticketAmount]];
    return label;
}

/**
 * Creates the textual information that is displayed on the Ticket's information view.
 *
 * This will show the Fare Zone Description to support backwards compatibility.
 * @return The text to be displayed, e.g.<br>
 *      "Fare Zone Description<br>
 *      Ticket Type Description<br>
 *      Rider Type Description<br>
 *      $1.42"
 */
- (NSString *)stackedLabel
{
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setMaximumFractionDigits:2];

    NSMutableString *label = [[NSMutableString alloc]init];

    if ([Utilities featuresFromId:@"display_fare_zone_desc"] && ([self.fareZoneCodeDesc length] > 0)) {
        [label appendString:self.fareZoneCodeDesc];
        [label appendString:@"\n"];
    }
    if ([self.ticketTypeDesc length] > 0) {
        [label appendString:self.ticketTypeDesc];
        [label appendString:@"\n"];
    }
    if ([self.riderTypeDesc length] > 0) {
        [label appendString:self.riderTypeDesc];
        [label appendString:@"\n"];
    }

    [label appendString:@"$"];
    [label appendString:[numberFormatter stringFromNumber:self.ticketAmount]];

    return label;
}

- (NSString *)details
{
    return [self label];
}

- (NSString *)activeDetails
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mma"];

    double liveTimeSeconds = [self.activationLiveTime intValue] * 60;

    return [NSString stringWithFormat:@"%@\nActive: %@ - %@",
            [self label],
            [timeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.activationDateTime doubleValue]]],
            [timeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.activationDateTime doubleValue] + liveTimeSeconds]]];
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)ticketId
{
    NSString *ticketId = [NSString stringWithFormat:@"%@ - %@", self.ticketGroupId, self.memberId];

    return [ticketId stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
}

/*
 * When an internet connection is unavailable, determine if an active ticket should become inactive,
 * or if an active/inactive ticket should be moved to history
 */
- (void)evaluateState:(NSDate *)currentDate
{
    int nowEpochTime = [currentDate timeIntervalSince1970];
    int expirationEpochTime = [self.expirationDateTime intValue];

    if (nowEpochTime >= expirationEpochTime) {  // If ticket is expired, move it to ticket history
        [self setType:HISTORY];

        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Ticket Model Error, couldn't save: %@", [error localizedDescription]);
        }
    } else if ([self.type isEqualToString:ACTIVE]) {
        int activationEpochTime = [self.activationDateTime intValue];
        int activationLiveMinutes = [self.activationLiveTime intValue];

        if (nowEpochTime >= (activationEpochTime + (activationLiveMinutes * SECONDS_PER_MINUTE))) {
            if (([self.activationCountMax intValue] > 0)
                && ([self.activationCount isEqualToNumber:self.activationCountMax])) { // If ticket has hit max activations, move to history
                [self setType:HISTORY];

                NSError *error;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Ticket Model Error, couldn't save: %@", [error localizedDescription]);
                }
            } else {
                [self setType:INACTIVE];

                NSError *error;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Ticket Model Error, couldn't save: %@", [error localizedDescription]);
                }
            }
        }
    } else if ([self.type isEqualToString:INACTIVE]) {
        if (([self.activationCountMax intValue] > 0)
            && ([self.activationCount isEqualToNumber:self.activationCountMax])) { // If ticket has hit max activations, move to history
            [self setType:HISTORY];

            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Ticket Model Error, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
}

/*
 * The first expirationdatetime value from the API in GetTicketsService is the initial expiration datetime up to when a ticket can be activated for the first (or only) time
 * The expiration datetime may change upon activation of the ticket (e.g. a 3-day pass activated at 2PM today will get a new expiration value of 2PM 3 days later)
 * A service day can also change the expiration datetime by allowing a ticket's use beyond the expiration datetime up until the end of the service day window
 * This function will be called initially from GetTicketsService to get an expiration date from the last activationDateTime (if available)
 * Will be called again from TicketPageViewController/TicketInformationViewController to get a true expiration date from the first activation event returned from GetTicketEventsService (if available)
 */
- (void)setExpirationDateForTicketFromDate:(NSDate *)date usingManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SERVICE_DAY_MODEL];
    NSArray *serviceDays = [managedObjectContext executeFetchRequest:fetchRequest error:nil];

    if ([serviceDays count] > 0) {
        for (ServiceDay *serviceDay in serviceDays) {
            if ([serviceDay.active boolValue]) {
                if ([serviceDay.typeSpecific boolValue]) {
                    // TODO: Not tested
                } else {
                    // 1. Go to midnight of the event's day
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    NSDateComponents *midnightComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
                    [midnightComponents setHour:0];
                    [midnightComponents setMinute:0];
                    [midnightComponents setSecond:0];

                    NSDate *dateAtMidnight = [calendar dateFromComponents:midnightComponents];

                    // 2. Add the ticket's expiration span
                    NSDate *preliminaryExpirationDate = [NSDate dateWithTimeInterval:[self.expirationSpan doubleValue] sinceDate:dateAtMidnight];

                    // 3. Get the service day of the preliminaryExpirationDate
                    NSInteger serviceStartOffset = [serviceDay.startSeconds integerValue];    // Number of seconds after midnight when a service day begins
                    NSInteger serviceSpan = [serviceDay.serviceSpan integerValue];            // Number of seconds after service start when window ends

                    NSDateComponents *expirationMidnightComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:preliminaryExpirationDate];
                    [expirationMidnightComponents setHour:0];
                    [expirationMidnightComponents setMinute:0];
                    [expirationMidnightComponents setSecond:0];

                    NSDate *dateAtExpirationMidnight = [calendar dateFromComponents:expirationMidnightComponents];
                    //int expirationSecondsFromMidnight = [preliminaryExpirationDate timeIntervalSince1970] - [dateAtExpirationMidnight timeIntervalSince1970];

                    // 4. IF the preliminaryExpirationDate lands WITHIN a service day's hours, set the expiration time to the end of the service day
                    //    ELSE the preliminaryExpirationDate lands OUTSIDE a service day's hours OR at the start of a service day, set the expiration time to the end of the PREVIOUS service day
                    /*if ((![Utilities isTimeDuringServiceDay:preliminaryExpirationDate usingManagedObjectContext:self.managedObjectContext]) // TODO: Currently, calling this function will only work if ONLY ONE service day is present
                        || (expirationSecondsFromMidnight == serviceStartOffset)) {*/
                        dateAtExpirationMidnight = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:dateAtExpirationMidnight options:0];
                    //}

                    NSDate *beginningOfExpirationServiceDay = [NSDate dateWithTimeInterval:serviceStartOffset sinceDate:dateAtExpirationMidnight];
                    NSDate *endOfExpirationServiceDay = [NSDate dateWithTimeInterval:serviceSpan sinceDate:beginningOfExpirationServiceDay];

                     NSTimeInterval intervalForDst = [Utilities adjustmentForDaylightSavingsTime:endOfExpirationServiceDay fromReferenceDate:date];

                    [self setExpirationDateTime:[NSNumber numberWithDouble:[[NSDate dateWithTimeInterval:intervalForDst sinceDate:endOfExpirationServiceDay] timeIntervalSince1970]]];

                    // TODO: Confirm that we break at this point since this service day apparently applies to all tickets anyway
                    break;
                }
            }
        }
    } else {
        if ([self.activationCount integerValue] > 0) {
            NSTimeInterval intervalForDST = [Utilities adjustmentForDaylightSavingsTime:[NSDate dateWithTimeIntervalSince1970:[self.expirationDateTime doubleValue]] fromReferenceDate:[NSDate dateWithTimeIntervalSince1970:[self.validStartDateTime doubleValue]]];

            [self setExpirationDateTime:[NSNumber numberWithDouble:([[self validStartDateTime]doubleValue] + [[self expirationSpan] doubleValue] + intervalForDST)]];
        } else {
            //Would add Daylight SavingsTime adjustment, but it might keep changing the time every time this function is called
        }
    }
}

@end
