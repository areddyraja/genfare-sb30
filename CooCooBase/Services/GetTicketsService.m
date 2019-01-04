//
//  GetTicketsService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetTicketsService.h"
#import "AppConstants.h"
#import "RuntimeData.h"
#import "ServiceDay.h"
#import "StationInfo.h"
#import "Ticket.h"
#import "TicketInformation.h"
#import "Utilities.h"

@implementation GetTicketsService
{
    NSString *ticketTypes;
     NSString *ticketSourceId;
    NSMutableDictionary *informationDictionary;
}

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = lis;
        self.managedObjectContext = context;
        ticketSourceId = [RuntimeData ticketSourceId:self.managedObjectContext];
        informationDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Class overrides


- (NSString *)host
{
    return [Utilities apiHost];
}

- (NSString *)uri
{
    return [NSString stringWithFormat:@"tickets/ticketwallet/%@", ticketSourceId];
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        [self setDataWithJson:[json valueForKey:@"result"]];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    NSArray *transactions = [json valueForKey:TRANSACTIONS];
    if (transactions != nil) {
        for (NSArray *transactionJson in transactions) {
            TicketInformation *information = [[TicketInformation alloc] init];
            
            information.firstName = [transactionJson valueForKey:@"firstname"];
            information.lastName = [transactionJson valueForKey:@"lastname"];
            information.creditCard = [transactionJson valueForKey:@"cclast4"];
            
            NSString *groupId = [transactionJson valueForKey:@"ticketgroupid"];
            
            information.ticketGroupId = groupId;
            
            [informationDictionary setObject:information forKey:groupId];
        }
    }
    
    NSArray *active = [json valueForKey:ACTIVE];
    if (active != nil) {
        [self setTicketsWithType:ACTIVE dataArray:active];
    }
    
    NSArray *inactive = [json valueForKey:INACTIVE];
    if (inactive != nil) {
        [self setTicketsWithType:INACTIVE dataArray:inactive];
    }
    
    NSArray *history = [json valueForKey:HISTORY];
    if (history != nil) {
        [self setTicketsWithType:HISTORY dataArray:history];
    }
    
    NSDictionary *ticketImages = [json valueForKey:TICKET_IMAGES];
    if (ticketImages != nil) {
        NSArray *keys = [ticketImages allKeys];
        
        for (NSString *key in keys) {
            NSString *imageUrlString = [[ticketImages valueForKey:key] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            if ([imageUrlString length] > 0) {
                NSRange range = [imageUrlString rangeOfString:@"/" options:NSBackwardsSearch];
                NSString *filename = [[imageUrlString substringFromIndex:range.location + 1] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
                
                NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
                NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
                
                NSString *ticketImagesPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:TICKET_IMAGES];
                
                NSError *error;
                if (![[NSFileManager defaultManager] fileExistsAtPath:ticketImagesPath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:ticketImagesPath withIntermediateDirectories:NO attributes:nil error:&error];
                }
                
                if (error == nil) {
                    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", ticketImagesPath, filename];
                    [imageData writeToFile:imagePath atomically:YES];
                }
            }
        }
    }
}

- (void)setTicketsWithType:(NSString *)ticketType
                 dataArray:(NSArray *)dataArray
{
    /*
     * When downloading the latest version of the ticket wallet, first delete any previously-staged tickets that have not yet been committed,
     * otherwise there will be duplicate staging tickets created every time GetTicketsService is called
     */
    [self deleteStagedTicketsOfTicketType:ticketType];
    
    NSUInteger arraySize = [dataArray count];
    for (int i = 0; i < arraySize; i++) {
        NSArray *ticketJson = [dataArray objectAtIndex:i];
        
        BOOL isStoredValue = [[ticketJson valueForKey:@"stored_value"] boolValue];
        
        /* TODO: (AC, April 2016)
         *       There's a passback bug with stored value tickets where a user can get two valid scans
         *       by first scanning the stored value ticket with the static, temporary ticket group ID + member ID,
         *       going back into the wallet and getting the real version of that ticket with a real group ID + member ID,
         *       and then scanning that ticket. To mitigate this for now, we are going to keep using the
         *       temporary ticket instead of the real one, so do not add any active stored value tickets here.
         */
        if (!isStoredValue || [ticketType isEqualToString:HISTORY]) {
            Ticket *ticket = (Ticket *)[NSEntityDescription insertNewObjectForEntityForName:TICKET_MODEL inManagedObjectContext:self.managedObjectContext];
            
            ticket.type = ticketType;
            
            if ([ticketType isEqualToString:HISTORY]) {
                [ticket setIsHistory:[NSNumber numberWithBool:YES]];
            }
            
            ticket.transitId = [ticketJson valueForKey:@"transitid"];
            
            // Have multiple ways to record ticket id just in case any info is missing
            // (though nothing besides the first case should ever actually happen)
            NSString *groupId = [ticketJson valueForKey:@"ticketgroupid"];
            NSString *memberId = [ticketJson valueForKey:@"memberid"];
            NSString *ticketId = [ticketJson valueForKey:@"id"];
            
            ticket.ticketGroupId = groupId;
            ticket.memberId = memberId;
            
            if ([groupId length] > 0) {
                if ([memberId length] > 0) {
                    NSString *idString = [NSString stringWithFormat:@"%@ - %@", groupId, memberId];
                    ticket.id = idString;
                } else {
                    ticket.id = groupId;
                }
                
                TicketInformation *information = [informationDictionary objectForKey:groupId];
                
                if (information != nil) {
                    ticket.firstName = information.firstName;
                    ticket.lastName = information.lastName;
                    ticket.creditCard = information.creditCard;
                }
            } else if ([memberId length] > 0) {
                if ([ticketId length] > 0) {
                    NSString *idString = [NSString stringWithFormat:@"%@ - %@", ticketId, memberId];
                    ticket.id = idString;
                } else {
                    ticket.id = memberId;
                }
            } else if ([ticketId length] > 0) {
                ticket.id = ticketId;
            }
            
            ticket.purchaseDateTime = [NSNumber numberWithDouble:[[ticketJson valueForKey:@"purchasedatetime"] doubleValue]];
            ticket.status = [ticketJson valueForKey:@"status"];
            ticket.statusCode = [NSNumber numberWithInteger:[[ticketJson valueForKey:@"statuscode"] intValue]];
            ticket.invoiceId = [ticketJson valueForKey:@"invoiceid"];
            ticket.deviceId = [ticketJson valueForKey:@"deviceid"];
            ticket.sellerId = [ticketJson valueForKey:@"sellerid"];
            ticket.ticketAmount = [NSNumber numberWithFloat:[[ticketJson valueForKey:@"ticketamount"] floatValue]];
            ticket.fareCode = [ticketJson valueForKey:@"farecode"];
            ticket.szType = [ticketJson valueForKey:@"sztype"];
            ticket.departId = [ticketJson valueForKey:@"departid"];
            ticket.arriveId = [ticketJson valueForKey:@"arriveid"];
            ticket.activationType = [ticketJson valueForKey:@"activationtype"];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            NSDate *firstActivationDate = [formatter dateFromString:[ticketJson valueForKey:@"first_activated_on"]];
            ticket.firstActivationDateTime = [NSNumber numberWithDouble:[firstActivationDate timeIntervalSince1970]];
            
            double activationDateSeconds = [[ticketJson valueForKey:@"activationdatetime"] doubleValue];
            ticket.activationDateTime = [NSNumber numberWithDouble:activationDateSeconds];
            ticket.activatedSeconds = [NSNumber numberWithDouble:activationDateSeconds];
            
            ticket.activationCount = [NSNumber numberWithInteger:[[ticketJson valueForKey:@"activationcount"] intValue]];
            ticket.activationCountMax = [NSNumber numberWithInteger:[[ticketJson valueForKey:@"activationcountmax"] intValue]];
            ticket.activationLiveTime = [NSNumber numberWithInteger:[[ticketJson valueForKey:@"activationtime"] intValue]];
            ticket.activationResetTime = [NSNumber numberWithInteger:[[ticketJson valueForKey:@"activationresettime"] intValue]];
            ticket.activationTransitionTime = [NSNumber numberWithInteger:[[ticketJson valueForKey:@"activationtransitiontime"] intValue]];
            ticket.inspections = [NSNumber numberWithInteger:[[ticketJson valueForKey:@"inspections"] intValue]];
            ticket.lastUpdated = [NSNumber numberWithDouble:[[ticketJson valueForKey:@"lastupdated"] doubleValue]];
            ticket.serviceCode = [ticketJson valueForKey:@"servicecode"];
            ticket.ticketTypeCode = [ticketJson valueForKey:@"tickettypecode"];
            ticket.riderTypeCode = [ticketJson valueForKey:@"ridertypecode"];
            ticket.fareZoneCode = [ticketJson valueForKey:@"farezonecode"];
            ticket.fareZoneCodeDesc = [ticketJson valueForKey:@"farezonedesc"];
            ticket.bfp = [ticketJson valueForKey:@"bfp"];
            ticket.riderTypeDesc = [ticketJson valueForKey:@"ridertypedesc"];
            ticket.ticketTypeDesc = [ticketJson valueForKey:@"tickettypedesc"];
            ticket.ticketTypeNote = [ticketJson valueForKey:@"tickettypenote"];
            ticket.validStartDateTime = [NSNumber numberWithDouble:[[ticketJson valueForKey:@"validstartdatetime"] doubleValue]];
            ticket.departStationId = [ticketJson valueForKey:@"departstationid"];
            ticket.arriveStationId = [ticketJson valueForKey:@"arrivestationid"];
            ticket.expirationSpan = [NSNumber numberWithDouble:[[ticketJson valueForKey:@"expirationspan"] doubleValue]];
            ticket.isStoredValue = [NSNumber numberWithBool:[[ticketJson valueForKey:@"stored_value"] boolValue]];
            
            if (([ticket.activationDateTime intValue] > DEFAULT_ACTIVATION_TIMESTAMP)
                && ([ticket.expirationSpan intValue] > 0)
                && ([ticket.activationCount intValue] > 0)) {
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SERVICE_DAY_MODEL];
                NSArray *serviceDays = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
                
                if ([serviceDays count] > 0) {
                    for (ServiceDay *serviceDay in serviceDays) {
                        if ([serviceDay.active boolValue]) {
                            if ([serviceDay.typeSpecific boolValue]) {
                                // TODO: Not tested
                            } else {
                                // 1. Go to midnight of the event's day
                                NSCalendar *calendar = [NSCalendar currentCalendar];
                                NSDateComponents *midnightComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:firstActivationDate];
                                [midnightComponents setHour:0];
                                [midnightComponents setMinute:0];
                                [midnightComponents setSecond:0];
                                
                                NSDate *beginningOfDay = [calendar dateFromComponents:midnightComponents];
                                
                                // 2. Add the ticket's expiration span
                                NSDate *preliminaryExpirationDate = [NSDate dateWithTimeInterval:[ticket.expirationSpan doubleValue] sinceDate:beginningOfDay];
                                
                                // 3. Get the service day of the preliminaryExpirationDate
                                NSInteger serviceStartOffset = [serviceDay.startSeconds integerValue];    // Number of seconds after midnight when a service day begins
                                NSInteger serviceSpan = [serviceDay.serviceSpan integerValue];            // Number of seconds after service start when window ends
                                
                                NSDateComponents *expirationMidnightComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:preliminaryExpirationDate];
                                [expirationMidnightComponents setHour:0];
                                [expirationMidnightComponents setMinute:0];
                                [expirationMidnightComponents setSecond:0];
                                
                                NSDate *dateAtExpirationMidnight = [calendar dateFromComponents:expirationMidnightComponents];
                                
                                NSDate *beginningOfExpirationServiceDay = [NSDate dateWithTimeInterval:serviceStartOffset sinceDate:dateAtExpirationMidnight];
                                NSDate *endOfExpirationServiceDay = [NSDate dateWithTimeInterval:serviceSpan sinceDate:beginningOfExpirationServiceDay];
                                
                                NSTimeInterval intervalForDst = [Utilities adjustmentForDaylightSavingsTime:endOfExpirationServiceDay fromReferenceDate:firstActivationDate];
                                
                                ticket.expirationDateTime = [NSNumber numberWithDouble:[[NSDate dateWithTimeInterval:intervalForDst sinceDate:endOfExpirationServiceDay] timeIntervalSince1970]];
                                
                                // TODO: Confirm that we break at this point since this service day apparently applies to all tickets anyway
                                break;
                            }
                        }
                    }
                } else {
                    NSDate *expirationDate = [NSDate dateWithTimeInterval:[ticket.expirationSpan doubleValue] sinceDate:firstActivationDate];
                    
                    ticket.expirationDateTime = [NSNumber numberWithDouble:[expirationDate timeIntervalSince1970]];
                }
            } else {
                ticket.expirationDateTime = [NSNumber numberWithDouble:[[ticketJson valueForKey:@"expirationdatetime"] doubleValue]];
            }
            
            if ([[NSDate dateWithTimeIntervalSince1970:[[ticket expirationDateTime] doubleValue]] compare:[NSDate date]] == NSOrderedAscending) {
                [ticket setType:HISTORY];
                [ticket setIsHistory:[NSNumber numberWithBool:YES]];
            }
            
            if ([ticketJson valueForKey:@"arrival_station"]) {
                [self createStation:[ticketJson valueForKey:@"arrival_station"]];
                
                ticket.arrivalStation = [NSNumber numberWithInt:[[[ticketJson valueForKey:@"arrival_station"] valueForKey:@"id"] intValue]];
            }
            
            if ([ticketJson valueForKey:@"departure_station"]) {
                [self createStation:[ticketJson valueForKey:@"departure_station"]];
                
                ticket.departureStation = [NSNumber numberWithInt:[[[ticketJson valueForKey:@"departure_station"] valueForKey:@"id"] intValue]];
            }
            
            ticket.isStaging = [NSNumber numberWithBool:YES];
            
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
}

- (void)deleteStagedTicketsOfTicketType:(NSString *)ticketType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:TICKET_MODEL inManagedObjectContext:self.managedObjectContext]];
    
    /* TODO: (AC, April 2016)
     *       There's a passback bug with stored value tickets where a user can get two valid scans
     *       by first scanning the stored value ticket with the static, temporary ticket group ID + member ID,
     *       going back into the wallet and getting the real version of that ticket with a real group ID + member ID,
     *       and then scanning that ticket. To mitigate this for now, we are going to keep using the
     *       temporary ticket instead of the real one, so do not delete active stored value tickets.
     */
    NSPredicate *predicate;
    if ([ticketType isEqualToString:HISTORY]) {
        predicate = [NSPredicate predicateWithFormat:@"deviceId == %@ AND type == %@ AND isStaging == %@",
                     ticketSourceId, ticketType, [NSNumber numberWithBool:YES]];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"deviceId == %@ AND type == %@ AND isStaging == %@ AND isStoredValue == %@",
                     ticketSourceId, ticketType, [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]];
    }
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *tickets = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Ticket *ticket in tickets) {
        [self.managedObjectContext deleteObject:ticket];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

- (void)createStation:(NSDictionary *)stationData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:STATION_INFO_MODEL inManagedObjectContext:self.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationId == %@",[stationData objectForKey:@"id"]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *station = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([station count] == 0) {
        StationInfo *stationInfo = (StationInfo *)[NSEntityDescription insertNewObjectForEntityForName:STATION_INFO_MODEL inManagedObjectContext:self.managedObjectContext];
        
        [stationInfo setStationId:[NSNumber numberWithInt:[[stationData objectForKey:@"id"] intValue]]];
        [stationInfo setTransitId:[NSNumber numberWithInt:[[stationData objectForKey:@"transit_id"] intValue]]];
        [stationInfo setName:[stationData objectForKey:@"name"]];
        [stationInfo setDisplayName:[stationData objectForKey:@"display_name"]];
        [stationInfo setCode:[stationData objectForKey:@"code"]];
        [stationInfo setLatitude:[NSNumber numberWithInt:[[stationData objectForKey:@"latitude"] doubleValue]]];
        [stationInfo setLongitude:[NSNumber numberWithInt:[[stationData objectForKey:@"longitude"] doubleValue]]];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        }
    }
}

@end
