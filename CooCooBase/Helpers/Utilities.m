//
//  Utilities.m
//  CooCooBase
//
//  Created by CooCooTech on 8/13/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "Utilities.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#import "AppConstants.h"
#import "Card.h"
#import "NSBundle+BaseResourcesBundle.h"
#import "ServiceDay.h"
#import "SSKeychain.h"
#import "Wallet.h"
#import "StoredData.h"
#import "CooCooAccountUtilities1.h"
#import "BaseViewController.h"
#import "Reachability.h"
#import "SplashScreenViewController.h"
#import "AppDelegate.h"


NSString *const KEY_IP_ADDRESS = @"ipAddress";
NSString *const ACCOUNT = @"user";
NSString *const TYPE_PLIST = @"plist";
NSString *const STRINGS_PLIST = @"Strings";
NSString *const COLORS_PLIST = @"Colors";
NSString *const FEATURES_PLIST = @"Features";

typedef NS_ENUM(NSUInteger, ExpirationType) {
    midNight,
    twentyFourHours,
    belowTwentyFourHours,
    endOfTransitDay
};

@implementation Utilities

+ (BOOL)isLightTheme{
    NSNumber *boolNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"is_light_theme"];
    
    return ([boolNumber intValue] == 1) ? YES : NO;
}
+ (float)statusBarHeight{
    float deviceStatusBar;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 2436:{
                deviceStatusBar=44.0;
            }
                break;
            default:{
                deviceStatusBar=STATUS_BAR_HEIGHT;
            }
                break;
        }
    }
    return deviceStatusBar;;
}
+ (NSString *)apiHost{
    return [self stringInfoForId:@"api_host"];
}
+ (NSString *)tenantId{
    return [[self stringInfoForId:@"tenantId"] uppercaseString];
}
+ (NSString *)dev_ApiHost{
    return [self stringInfoForId:@"dev_api_host"];
}
+ (NSString *)auth_host{
    return [self stringInfoForId:@"auth_host"];
}
+ (NSString *)apiUrl{
    if ([[self apiHost] containsString:@"localhost"]) {
        return [NSString stringWithFormat:@"http://%@", [self apiHost]];
    } else {
        return [NSString stringWithFormat:@"https://%@", [self apiHost]];
    }
}
+ (NSString *)apiEnvironment{
    return [self stringInfoForId:@"api_environment"];
}
+ (NSString *)wsHost{
    return [self stringInfoForId:@"ws_host"];
}
+ (NSString *)transitId{
    return [self stringInfoForId:@"transit_id"];
}
+ (NSString *)authUsername{
    return [self stringInfoForId:@"auth_username"];
}
+ (NSString *)authPassword{
    return [self stringInfoForId:@"auth_password"];
}
+ (NSString *)urlencode:(NSString *)string {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
+ (NSDictionary *)headers:(NSString *)url{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    headers = [Utilities setMyAuthorizationHeaderFieldWithUsername:[Utilities authUsername] password:[Utilities authPassword] url:url];
    //    [Utilities setMyAuthorizationHeaderFieldWithUsername:[Utilities authUsername] password:[Utilities authPassword]];
    return headers;
}
+ (NSString *)ipAddress{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedIpAddress = [defaults stringForKey:KEY_IP_ADDRESS];
    if ([savedIpAddress length] > 0) {
        return savedIpAddress;
    } else {
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        NSString *wifiAddress = nil;
        NSString *cellAddress = nil;
        
        // Retrieve the current interfaces - returns 0 on success
        if (!getifaddrs(&interfaces)) {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            
            while (temp_addr != NULL) {
                sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
                
                if (sa_type == AF_INET) {
                    NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                    NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                    
                    if ([name isEqualToString:@"en0"]) {
                        // Interface is the wifi connection
                        wifiAddress = addr;
                    } else if ([name isEqualToString:@"pdp_ip0"]) {
                        // Interface is the cell connection
                        cellAddress = addr;
                    }
                }
                
                temp_addr = temp_addr->ifa_next;
            }
            
            // Deallocate resources
            freeifaddrs(interfaces);
        }
        
        NSString *ipAddress = wifiAddress ? wifiAddress : cellAddress;
        
        if ([ipAddress length] > 0) {
            [defaults setObject:ipAddress forKey:KEY_IP_ADDRESS];
            
            [defaults synchronize];
            
            return ipAddress;
        } else {
            return @"0.0.0.0";
        }
    }
}
+ (NSString *)generateUUID{
    // Create a universally unique identifier
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    
    uuidString=[uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    //Change default accessibilty permission to be always accessible
    [SSKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
    
    // Save the CFUUID string to keychain for persistence if user uninstalls the app
    [SSKeychain setPassword:uuidString forService:[[NSBundle mainBundle] bundleIdentifier] account:ACCOUNT];
    return uuidString;
}
+ (NSString *)deviceId{
    NSArray *allKeychainAccounts = [SSKeychain accountsForService:[[NSBundle mainBundle] bundleIdentifier]];
    
    if ([allKeychainAccounts count] > 0){
        for (NSDictionary *singleAccount in allKeychainAccounts){
            id obj = [singleAccount objectForKey:@"acct"];
            if([obj isKindOfClass:[NSString class]]){
                if ([obj isEqualToString:ACCOUNT]){
                    NSString *itemPermission = [singleAccount objectForKey:@"pdmn"];
                    
                    NSString *password = [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier]
                                                                account:[singleAccount objectForKey:@"acct"]];
                    
                    if ([itemPermission isEqualToString:@"dk"]) {
                        //permission code dk - kSecAttrAccessibleAlways - that is what we want to have
                    } else {
                        //resave item with correct permissions
                        
                        //Change default accessibilty permission to be always accessible
                        [SSKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
                        
                        NSError *error;
                        // Save the CFUUID string to keychain for persistence if user uninstalls the app
                        [SSKeychain setPassword:password forService:[[NSBundle mainBundle] bundleIdentifier] account:[singleAccount objectForKey:@"acct"] error:&error];
                        
                        if ([error code] == errSecItemNotFound) {
                            NSLog(@"Password not found");
                        } else if (error != nil) {
                            NSLog(@"Some other error occurred: %@", [error localizedDescription]);
                        } else {
                            // NSLog(@"account was updated with corrected permissions. This will always get called in simulator");
                        }
                    }
                    
                    return password;
                } else {
                    // NSLog(@"Another item is %@", [singleAccount objectForKey:@"acct"]);
                    //some other itmes saved, keep looking for ACCOUNT
                }
            }
        }
        //  NSLog(@"Some other items present,but not an Account");
        return [self generateUUID];
    }
    else {
        NSLog(@"No Accounts available. Create UUID. The app is launched for a first time on this phone.");
        
        return [self generateUUID];
    }
}
+ (NSDate *)calculateExpiryDate:(WalletContents* )walletContent{
    // calculateExpiryDate based on activationDate,valueRemaining and expirationType;
    NSString * expirationType = @"midNight";
    NSDate * expirationDate;
    NSArray *items = @[@"midNight", @"twentyFourHours", @"belowTwentyFourHours", @"endOfTransitDay"];
    int item = (int)[items indexOfObject:expirationType];
    switch (item) {
        case midNight:
            NSLog(@"midNight");
            expirationDate = [self midNightCalculation:walletContent];
            break;
        case twentyFourHours:
            NSLog(@"twentyFourHours");
            break;
        case belowTwentyFourHours:
            NSLog(@"belowTwentyFourHours");
            break;
        case endOfTransitDay:
            NSLog(@"endOfTransitDay");
            break;
        default:
            break;
    }
    return expirationDate;
}

+(NSDate *)midNightCalculation:(WalletContents* )walletContent{
    float days = [[walletContent valueRemaining] floatValue];
    NSDate * activationDate = [self getActivationDate:walletContent];
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:activationDate];
    [components setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    components.day += days;
    [components setSecond:components.second -1];
    return [gregorian dateFromComponents:components];
}

+(NSDate *)getActivationDate:(WalletContents* )walletContent{
    NSDate * activationDate;
    if ([walletContent.type isEqualToString:PAY_AS_YOU_GO] || [walletContent.type isEqualToString:@"Single ride"]) {
        activationDate = [NSDate dateWithTimeIntervalSince1970:walletContent.ticketActivationExpiryDate.longLongValue];
    }else{
        activationDate = [NSDate dateWithTimeIntervalSince1970:[walletContent.activationDate doubleValue]/1000];
    }
    return activationDate;
}

+(NSDate *)getExpirationDateFromCurrentDate:(WalletContents* )walletContent{
    float days = [[walletContent valueRemaining] floatValue];
    NSDate * activationDate = [NSDate date];
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:activationDate];
    [components setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    components.day += days;
    [components setSecond:components.second -1];
    return [gregorian dateFromComponents:components];
}

+ (NSString *)appCurrentVersion{
    NSString * currentVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey];
    return currentVersionString;
}
+ (NSString*)walletId{
    NSString *walletId = [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier]
                                                account:ACCOUNT];
    return walletId;
}
+ (NSString *)sessionId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:KEY_SESSION_ID];
}
+ (NSString *)accessToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:COMMON_KEY_ACCESS_TOKEN];
}
+ (NSString *)commonaccessToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:COMMON_KEY_ACCESS_TOKEN];
}
+ (NSString *)stringInfoForId:(NSString *)infoId{
    NSString *infoString = [[NSBundle mainBundle] objectForInfoDictionaryKey:infoId];
    if (!([infoString length] > 0)) {
        infoString = [[NSBundle baseResourcesBundle] objectForInfoDictionaryKey:infoId];
        if (!([infoString length] > 0)) {
            //if using tests the bundle have to be accessed in the following way. Key should be present in the Info.Plist
            infoString = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:infoId];
        }
    }
    return infoString;
}
+ (NSString *)stringResourceForId:(NSString *)resourceId{
    NSString *string = @"";
    NSString *stringsPlistPath = [[NSBundle mainBundle] pathForResource:STRINGS_PLIST ofType:TYPE_PLIST];
    if ([stringsPlistPath length] > 0) {
        string = [[NSDictionary alloc] initWithContentsOfFile:stringsPlistPath][resourceId];
    }
    if (!([string length] > 0)) {
        stringsPlistPath = [[NSBundle baseResourcesBundle] pathForResource:STRINGS_PLIST ofType:TYPE_PLIST];
        
        string = [[NSDictionary alloc] initWithContentsOfFile:stringsPlistPath][resourceId];
    }
    return string;
}
+ (NSString *)colorHexStringFromId:(NSString *)resourceId{
    NSString *colorHexString = @"";
    NSString *colorsPlistPath = [[NSBundle mainBundle] pathForResource:COLORS_PLIST ofType:TYPE_PLIST];
    if ([colorsPlistPath length] > 0) {
        NSDictionary *colorsDictionary = [[NSDictionary alloc] initWithContentsOfFile:colorsPlistPath];
        colorHexString = [colorsDictionary valueForKey:resourceId];
    }
    if (!([colorHexString length] > 0)) {
        colorsPlistPath = [[NSBundle baseResourcesBundle] pathForResource:COLORS_PLIST ofType:TYPE_PLIST];
        NSDictionary *colorsDictionary = [[NSDictionary alloc] initWithContentsOfFile:colorsPlistPath];
        colorHexString = [colorsDictionary valueForKey:resourceId];
    }
    return colorHexString;
}
+ (BOOL)featuresFromId:(NSString *)resourceId{
    BOOL featuresBool;
    NSString *featuresPlistPath = [[NSBundle mainBundle] pathForResource:FEATURES_PLIST ofType:TYPE_PLIST];
    if ([featuresPlistPath length] > 0) {
        NSDictionary *featuresDictionary = [[NSDictionary alloc] initWithContentsOfFile:featuresPlistPath];
        featuresBool = [[featuresDictionary valueForKey:resourceId] boolValue];
    } else {
        featuresPlistPath = [[NSBundle baseResourcesBundle] pathForResource:FEATURES_PLIST ofType:TYPE_PLIST];
        NSDictionary *featuresDictionary = [[NSDictionary alloc] initWithContentsOfFile:featuresPlistPath];
        featuresBool = [[featuresDictionary valueForKey:resourceId] boolValue];
    }
    return featuresBool;
}

+ (NSString *)welcomeStringForUserData:(UserData *)userData{
    NSString *welcome = [NSString stringWithFormat:@"%@, ", [Utilities stringResourceForId:@"welcome"]];
    NSString *welcomeString = nil;
    NSString *firstName = userData.firstName;
    if ([firstName length] > 0) {
        NSArray *welcomeArray = [[NSArray alloc] initWithObjects:welcome, firstName, nil];
        welcomeString = [welcomeArray componentsJoinedByString:@""];
    } else {
        NSString *lastName = userData.lastName;
        if ([lastName length] > 0) {
            NSArray *welcomeArray = [[NSArray alloc] initWithObjects:welcome, lastName, nil];
            welcomeString = [welcomeArray componentsJoinedByString:@""];
        } else {
            NSString *email = userData.email;
            
            if ([email length] > 0) {
                NSArray *welcomeArray = nil;
                
                if ([email rangeOfString:@"@"].location != NSNotFound) {
                    NSString *emailName = [email substringWithRange:NSMakeRange(0, [email rangeOfString:@"@"].location)];
                    
                    welcomeArray = [[NSArray alloc] initWithObjects:welcome, emailName, nil];
                } else {
                    // AC (July 15) - This case where an email address is missing an ampersand should never happen, but add a safety net to prevent crashes anyway
                    welcomeArray = [[NSArray alloc] initWithObjects:welcome, email, nil];
                }
                
                welcomeString = [welcomeArray componentsJoinedByString:@""];
            } else {
                welcomeString = [Utilities stringResourceForId:@"welcome"];
            }
        }
    }
    
    return welcomeString;
}

/*
 + (BOOL)isValidEmail:(NSString *)email
 {
 NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_EMAIL];
 
 return [emailTest evaluateWithObject:email];
 }
 */

+ (NSDate *)dateFromUTCString:(NSString *)inputString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [dateFormat dateFromString:inputString];
}

+ (NSTimeInterval)adjustmentForDaylightSavingsTime:(NSDate *)date fromReferenceDate:(NSDate *)referenceDate{
    // "date" is the ending date for which you intend offset. the "referenceDate" is the starting date of the span.
    // we get difference between the offsets from GMT for the dates
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger referenceDateOffset = [timeZone secondsFromGMTForDate:referenceDate];
    NSInteger toChangeDateOffset = [timeZone secondsFromGMTForDate:date];
    
    return referenceDateOffset - toChangeDateOffset;
}

+ (BOOL)isTimeDuringServiceDay:(NSDate *)date usingManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SERVICE_DAY_MODEL];
    NSError *error = nil;
    NSArray *serviceDays = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([serviceDays count] > 0) {
        for (ServiceDay *serviceDay in serviceDays) {
            if ([serviceDay.active boolValue]) {
                if ([serviceDay.typeSpecific boolValue]) {
                    // TODO: Not tested
                } else {
                    NSInteger serviceStartOffset = [[serviceDay startSeconds] integerValue];    // Number of seconds after midnight when a service day begins
                    NSInteger serviceSpan = [[serviceDay serviceSpan] integerValue];            // Number of seconds after service start when window ends
                    
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    NSDateComponents *midnightComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
                    [midnightComponents setHour:0];
                    [midnightComponents setMinute:0];
                    [midnightComponents setSecond:0];
                    
                    NSDate *dateAtMidnight = [calendar dateFromComponents:midnightComponents];
                    
                    // If the current time is AFTER the offset, then the starting midnight is the same midnight as the offset
                    // If the current time is BEFORE the offset (e.g. currently 2AM and offset is 4AM), start at "yesterday's" midnight
                    NSDate *now = [NSDate date];
                    int nowSecondsFromMidnight = [now timeIntervalSince1970] - [dateAtMidnight timeIntervalSince1970];
                    
                    if (nowSecondsFromMidnight < serviceStartOffset) {
                        dateAtMidnight = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:dateAtMidnight options:0];
                    }
                    
                    NSDate *beginningOfServiceDay = [NSDate dateWithTimeInterval:serviceStartOffset sinceDate:dateAtMidnight];
                    NSDate *endOfServiceDay = [NSDate dateWithTimeInterval:serviceSpan sinceDate:beginningOfServiceDay];
                    
                    if ((([beginningOfServiceDay compare:date] == NSOrderedAscending) || ([beginningOfServiceDay compare:date] == NSOrderedSame))   // beginningOfServiceDay is earlier OR the same as date
                        && (([endOfServiceDay compare:date] == NSOrderedDescending) || ([endOfServiceDay compare:date] == NSOrderedSame))) {   // endOfServiceDay is later than OR the same as date
                        return YES;
                    }
                }
            }
        }
        return NO;
    } else {
        return YES;
    }
}

+ (void)clearKeychainOnTheFirstRun{
    // Clear keychain on first run in case of reinstallation
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        // Delete values from keychain here
        [SSKeychain deletePasswordForService:[[NSBundle mainBundle] bundleIdentifier] account:WALLET_MODEL];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *)getCards:(NSManagedObjectContext *)managedObjectContext{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CARD_MODEL inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isTemporary == 0"];
    [fetchRequest setPredicate:predicate];
    
    // Sorting cards from oldest to newest
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDateTime" ascending:YES];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    return result;
}

+ (Ticket *)currentTicket:(NSManagedObjectContext *)managedObjectContext{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TICKET_MODEL
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCurrent == %@", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *tickets = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([tickets count] > 0) {
        return [tickets objectAtIndex:0];
    }
    
    return nil;
}

// Commit STAGING tickets by deleting the old, local copy of tickets and setting isStaging to NO
+ (void)commitTickets:(NSString *)ticketSourceId managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    // If user is currently looking at a ticket, set the new matching commit ticket as current to replace the old one
    // Save properties as currentTicket may be deleted and nullified
    Ticket *currentTicket = [Utilities currentTicket:managedObjectContext];
    NSString *currentTicketSourceId = currentTicket.deviceId;
    NSString *currentTicketGroupId = currentTicket.ticketGroupId;
    NSString *currentTicketMemberId = currentTicket.memberId;
    NSTimeInterval currentTicketFirstActivation = [currentTicket.firstActivationDateTime doubleValue];
    
    /* TODO: (AC, April 2016)
     *       There's a passback bug with stored value tickets where a user can get two valid scans
     *       by first scanning the stored value ticket with the static, temporary ticket group ID + member ID,
     *       going back into the wallet and getting the real version of that ticket with a real group ID + member ID,
     *       and then scanning that ticket. To mitigate this for now, we are going to keep using the
     *       temporary ticket instead of the real one, so do not delete non-history stored value tickets here.
     */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TICKET_MODEL
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deviceId == %@ AND isStaging == %@ AND isStoredValue == %@",
                              ticketSourceId, [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *oldTickets = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Ticket *ticket in oldTickets) {
        [managedObjectContext deleteObject:ticket];
    }
    
    // Also delete saved tickets that are stored value and in history
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:TICKET_MODEL
                         inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    predicate = [NSPredicate predicateWithFormat:@"deviceId == %@ AND isStaging == %@ AND isStoredValue == %@ AND type == %@",
                 ticketSourceId, [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES], HISTORY];
    [fetchRequest setPredicate:predicate];
    
    NSArray *oldHistoryTickets = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Ticket *ticket in oldHistoryTickets) {
        [managedObjectContext deleteObject:ticket];
    }
    
    // Set STAGED tickets to no longer STAGED
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:TICKET_MODEL
                         inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    predicate = [NSPredicate predicateWithFormat:@"deviceId == %@ AND isStaging == %@",
                 ticketSourceId, [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    
    NSArray *stagedTickets = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Ticket *ticket in stagedTickets) {
        [ticket setIsStaging:[NSNumber numberWithBool:NO]];
        
        if (([currentTicketSourceId length] > 0) && [ticket.deviceId isEqualToString:currentTicketSourceId]
            && [ticket.ticketGroupId isEqualToString:currentTicketGroupId]
            && [ticket.memberId isEqualToString:currentTicketMemberId]
            && ([ticket.firstActivationDateTime doubleValue] == currentTicketFirstActivation)) {
            [ticket setIsCurrent:[NSNumber numberWithBool:YES]];
            
            currentTicket = nil;
        }
        
        if (![managedObjectContext save:&error]) {
            NSLog(@"TicketsViewController Commit Ticket Error, couldn't save: %@", [error localizedDescription]);
        }
    }
}

/*
 * Return YES if ticket was successfully set as current
 */
+ (BOOL)setCurrentTicket:(NSString *)ticketSourceId
           ticketGroupId:(NSString *)ticketGroupId
                memberId:(NSString *)memberId
 firstActivationDateTime:(NSTimeInterval)firstActivationDateTime
    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    BOOL currentTicketSuccessfullySet = NO;
    
    // First check if there is already a current ticket and set it as no longer current
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:TICKET_MODEL
                                        inManagedObjectContext:managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCurrent == %@", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *currentTickets = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([currentTickets count] > 0) {
        Ticket *currentTicket = [currentTickets objectAtIndex:0];
        
        // If the current ticket is already the desired ticket, no need to set it as current
        if ([currentTicket.deviceId isEqualToString:ticketSourceId] && [currentTicket.ticketGroupId isEqualToString:ticketGroupId]
            && [currentTicket.memberId isEqualToString:memberId]
            && ([currentTicket.firstActivationDateTime doubleValue] == firstActivationDateTime)) {
            currentTicketSuccessfullySet = YES;
        } else {
            [currentTicket setIsCurrent:[NSNumber numberWithBool:NO]];
            
            if (![managedObjectContext save:&error]) {
                NSLog(@"TicketsViewController Existing Current Ticket Error, couldn't save: %@", [error localizedDescription]);
            }
            
            // Mark desired ticket as new current ticket
            fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:TICKET_MODEL
                                                inManagedObjectContext:managedObjectContext]];
            
            predicate = [NSPredicate predicateWithFormat:@"deviceId == %@ AND ticketGroupId == %@ AND memberId == %@ AND firstActivationDateTime == %lf",
                         ticketSourceId, ticketGroupId, memberId, firstActivationDateTime];
            [fetchRequest setPredicate:predicate];
            
            NSArray *tickets = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if ([tickets count] > 0) {
                Ticket *ticket = [tickets objectAtIndex:0];
                
                [ticket setIsCurrent:[NSNumber numberWithBool:YES]];
                
                currentTicketSuccessfullySet = [managedObjectContext save:&error];
                
                if (!currentTicketSuccessfullySet) {
                    NSLog(@"TicketsViewController Set Current Ticket Error, couldn't save: %@", [error localizedDescription]);
                }
            }
        }
    } else {    // There is not already a current ticket
        // Mark desired ticket as new current ticket
        fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:TICKET_MODEL
                                            inManagedObjectContext:managedObjectContext]];
        
        predicate = [NSPredicate predicateWithFormat:@"deviceId == %@ AND ticketGroupId == %@ AND memberId == %@ AND firstActivationDateTime == %lf",
                     ticketSourceId, ticketGroupId, memberId, firstActivationDateTime];
        [fetchRequest setPredicate:predicate];
        
        NSArray *tickets = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([tickets count] > 0) {
            Ticket *ticket = [tickets objectAtIndex:0];
            
            [ticket setIsCurrent:[NSNumber numberWithBool:YES]];
            
            currentTicketSuccessfullySet = [managedObjectContext save:&error];
            
            if (!currentTicketSuccessfullySet) {
                NSLog(@"TicketsViewController Set Current Ticket Error, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
    
    return currentTicketSuccessfullySet;
}

+ (NSMutableDictionary *)setMyAuthorizationHeaderFieldWithUsername:(NSString *)username
                                                          password:(NSString *)password
                                                               url:(NSString *)url{
    //    NSLog(@"Got it accessToken ==== %@",[Utilities accessToken]);
    NSMutableDictionary * headerDict = [[NSMutableDictionary alloc] init];
    
    //    NSLog(@"URL--------------->%@<------",url);
    
    
    //    if ([url rangeOfString:@"/login"].location != NSNotFound || [url rangeOfString:@"/mobile/users?"].location != NSNotFound){
    //        NSString * base64String = [Utilities commonaccessToken];
    //        [headerDict setValue:[NSString stringWithFormat:@"bearer %@", base64String] forKey:@"Authorization"];
    //        [headerDict setValue:@"application/json" forKey:@"Accept"];
    //    }else
    
    if ([url rangeOfString:@"/oauth/"].location == NSNotFound ){
        //        NSString * base64String = [Utilities commonaccessToken];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //    [defaults setObject:[json objectForKey:@"access_token"] forKey:KEY_ACCESS_TOKEN];
        //        [defaults setObject:[json objectForKey:@"access_token"] forKey:COMMON_KEY_ACCESS_TOKEN];
        NSLog(@"\naccessToken is:->%@<-",[defaults stringForKey:COMMON_KEY_ACCESS_TOKEN]);

        NSString * base64String = [defaults stringForKey:COMMON_KEY_ACCESS_TOKEN];
        
        if( [url rangeOfString:@"mobile/app/iOS"].location == NSNotFound){
            [headerDict setValue:[NSString stringWithFormat:@"bearer %@", base64String] forKey:@"Authorization"];

        }
        [headerDict setValue:@"application/json" forKey:@"Accept"];
        NSString * currentAppVersion = [Utilities appCurrentVersion];
        [headerDict setValue:@"iOS" forKey:@"app_os"];
        [headerDict setValue:currentAppVersion forKey:@"app_version"];
        [headerDict setValue:[Utilities deviceId] forKey:@"DeviceId"];
        [headerDict setValue:@"application/json" forKey:@"Content-Type"];

    }else{
        NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", username, password];
        NSString * base64String = [Utilities stringToBase64:basicAuthCredentials];
        if( [url rangeOfString:@"mobile/app/iOS"].location == NSNotFound)
            [headerDict setValue:[NSString stringWithFormat:@"Basic %@", base64String] forKey:@"Authorization"];
        [headerDict setValue:@"application/json" forKey:@"Accept"];
        NSString * currentAppVersion = [Utilities appCurrentVersion];
        [headerDict setValue:@"iOS" forKey:@"app_os"];
        [headerDict setValue:currentAppVersion forKey:@"app_version"];
        [headerDict setValue:[Utilities deviceId] forKey:@"DeviceId"];
        [headerDict setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
//        [headerDict setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forKey:@"Content-Type"];

    }
    
    return headerDict;
}

+ (NSString *)stringToBase64:(NSString *)plainString {
    NSData *plainData = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSLog(@"%@", base64String);
    return base64String;
}
+ (UIViewController*)topMostController{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if([topController isKindOfClass:[SplashScreenViewController class]]){
        topController=[(SplashScreenViewController*)topController navController];
    }
    return topController;
}
+ (void) popToRootViewController {
    @try {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *controllers = appDelegate.navigationController.viewControllers;
        if (controllers && [controllers count] > 0) {
            UIViewController *loginController = [controllers objectAtIndex:0];
            [appDelegate.navigationController popToViewController:loginController animated:YES];
        }
    }
    @catch (NSException *exception) {
        // Throws an exception
    }
}
+(NSString *)capitalizedOnlyFirstLetter :(NSString *)plainString{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    NSString *firstChar = [plainString substringToIndex:1];
    NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
    NSString *resultString = [[folded uppercaseString] stringByAppendingString:[plainString substringFromIndex:1]];
    return resultString;
}

+ (int)getCurrentWalletState:(NSManagedObjectContext *)managedObjectContext{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:WALLET_MODEL];
    NSString * walletId = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@",walletId]];
    NSError *error = nil;
    NSArray *walletarray = [managedObjectContext executeFetchRequest:request error:&error];
    WalletContent *walletContent  = (WalletContent *)[walletarray lastObject];
    long currentDateTime = (long long)([[NSDate date] timeIntervalSince1970] ); //if it's High Expired
    long farecodeExpiryDateTime = (long long)([walletContent farecodeExpiryDateTime].longLongValue); //if it's High Valid
    if (farecodeExpiryDateTime != 0 && farecodeExpiryDateTime < currentDateTime) {
        return WALLET_FARECODE_STATUS_EXPIRED;
    }else{
        return [[walletContent statusId] intValue];
    }
}

#pragma mark - Color String Methods
+ (NSString *)themeColor{
    NSString * colorString = [NSString stringWithFormat:@"%@ThemeColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)continueButtonBgColor{
    NSString * colorString = [NSString stringWithFormat:@"%@ContinueBtnBGColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)tableBgColor{
    NSString * colorString = [NSString stringWithFormat:@"%@TableBgColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}

+ (NSString *)textDarkColor{
    NSString * colorString = [NSString stringWithFormat:@"%@TextDarkColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}

+ (NSString *)buttonBGColor{
    NSString * colorString = [NSString stringWithFormat:@"%@ButtonBGColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)linkTextColor{
    NSString * colorString = [NSString stringWithFormat:@"%@LinkTextColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)textInactiveColor{
    NSString * colorString = [NSString stringWithFormat:@"%@TextInactiveColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)pagerStripBgColor{
    NSString * colorString = [NSString stringWithFormat:@"%@PagerStripBgColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)mainBgColor{
    NSString * colorString = [NSString stringWithFormat:@"%@MainBgColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)highLightColor{
    NSString * colorString = [NSString stringWithFormat:@"%@HighLightColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)tableViewHeaderBGColor{
    NSString * colorString = [NSString stringWithFormat:@"%@TableViewHeaderBGColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)ticketBorderColor{
    NSString * colorString = [NSString stringWithFormat:@"%@TicketBorderColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)bGColor{
    NSString * colorString = [NSString stringWithFormat:@"%@BGColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
+ (NSString *)pageMenuColor{
    NSString * colorString = [NSString stringWithFormat:@"%@PageMenuColor",[[Utilities tenantId] lowercaseString]];
    return colorString;
}
#pragma mark - Alert String Methods
+ (NSString *)noPassesAlert{
    NSString * appendedString = [NSString stringWithFormat:@"%@NoPassesAlert",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)noUsedTickets{
    NSString * appendedString = [NSString stringWithFormat:@"%@NoUsedTickets",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)confirmLogoutTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@ConfirmLogoutTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)confirmLogoutMessage{
    NSString * appendedString = [NSString stringWithFormat:@"%@ConfirmLogoutMessage",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)logoutButtonTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@LogoutButtonTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)cancelButtonTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@CancelButtonTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)purchaseProductTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@PurchaseProductTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)purchaseProductMessage{
    NSString * appendedString = [NSString stringWithFormat:@"%@PurchaseProductMessage",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)closeButtonTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@CloseButtonTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)deleteCreditCardTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@DeleteCreditCardTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)deleteCreditCardMessage{
    NSString * appendedString = [NSString stringWithFormat:@"%@DeleteCreditCardMessage",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)retriveCreditCardAlertTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@RetriveCreditCardAlertTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)payAsYouGoAlertTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@PayAsYouGoAlertTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)payAsYouGoMessage{
    NSString * appendedString = [NSString stringWithFormat:@"%@PayAsYouGoMessage",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)walletUsingAlreadyMessage{
    NSString * appendedString = [NSString stringWithFormat:@"%@WalletUsingAlreadyMessage",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)navigationBarTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@NavigationBarTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)historyTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@HistoryTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)createWalletTitle{
    NSString * appendedString = [NSString stringWithFormat:@"%@CreateWalletTitle",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)appstoreLink{
    NSString * appendedString = [NSString stringWithFormat:@"%@AppstoreLink",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)stagingLink{
    NSString * appendedString = [NSString stringWithFormat:@"%@StagingLink",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)uatLink{
    NSString * appendedString = [NSString stringWithFormat:@"%@UatLink",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}
+ (NSString *)topNavColor{
    NSString * appendedString = [NSString stringWithFormat:@"%@TopNavBarColor",[[Utilities tenantId] lowercaseString]];
    return appendedString;
}


#pragma mark - Dynamic ViewController Methods
+ (NSString *)walletInstructionsViewController{
    NSString * controllerString = [NSString stringWithFormat:@"%@WalletInstructionsViewController",[[Utilities tenantId] lowercaseString]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    NSString *firstChar = [controllerString substringToIndex:1];
    NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
    NSString *resultControllerString = [[folded uppercaseString] stringByAppendingString:[controllerString substringFromIndex:1]];
    return resultControllerString;
}
+ (NSString *)HelpViewController{
    NSString * controllerString = [NSString stringWithFormat:@"%@HelpViewController",[[Utilities tenantId] lowercaseString]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    NSString *firstChar = [controllerString substringToIndex:1];
    NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
    NSString *resultControllerString = [[folded uppercaseString] stringByAppendingString:[controllerString substringFromIndex:1]];
    return resultControllerString;
}
+ (NSString *)TermsViewController{
    NSString * controllerString = [NSString stringWithFormat:@"%@TermsViewController",[[Utilities tenantId] lowercaseString]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    NSString *firstChar = [controllerString substringToIndex:1];
    NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
    NSString *resultControllerString = [[folded uppercaseString] stringByAppendingString:[controllerString substringFromIndex:1]];
    return resultControllerString;
}
+ (NSString *)PrivacyViewController{
    NSString * controllerString = [NSString stringWithFormat:@"%@PrivacyViewController",[[Utilities tenantId] lowercaseString]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    NSString *firstChar = [controllerString substringToIndex:1];
    NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
    NSString *resultControllerString = [[folded uppercaseString] stringByAppendingString:[controllerString substringFromIndex:1]];
    return resultControllerString;
}


+ (NSString *)schedulesHost{
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        return [self stringInfoForId:@"schedules_host"];
    }else if ([tenantId isEqualToString:@"CDTA"]){
        return @"api.cdta.org";
    }else{}
    return [self stringInfoForId:@"schedules_host"];
}
+(BOOL)isNetWorkAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}
+(CGFloat)currentDeviceHeight{
    int height = [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.height;
    NSString *deviceModel;
    CGFloat deviceHeight;
    switch (height) {
        case 568:
            deviceModel = @"iPhone 5s or SE";
            deviceHeight = height;
            break;
        case 667:
            deviceModel = @"iPhone 8/7/6s/6";
            deviceHeight = height;
            break;
        case 736:
            deviceModel = @"iPhone 8/7/6s/6 Plus";
            deviceHeight = height;
            break;
        case 812:
            deviceModel = @"iPhone X";
            deviceHeight = height - 26;
            break;
        default:
            deviceModel = @"Dunno. Maybe it's an Android...?";
            deviceHeight = 500;
            break;
    }
    return deviceHeight;
}

#pragma mark - Get values from User Defaults

+ (NSString *)getValueFromDefaultsForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:key];
}

+ (void)removeValueFromDefaults:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}

+ (void) saveAddress:(NSString *)address lat:(NSString *)lat long:(NSString *)longi for:(NSString *)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *saveString = [NSString stringWithFormat:@"%@|%@|%@",address,lat,longi];
    [defaults setObject:saveString forKey:type];
    [defaults synchronize];
}

// Address will be saved in format "2204, Glencoe Hills Av, Ann Arbor, MI|12.0009298|-34.4234234"
+ (NSString *)getObjectForLocation:(NSString *)location {
    //TODO - Need to implement this method to get the saved addresses
    return nil;
}

@end
