//
//  Utilities.h
//  CooCooBase
//
//  Created by CooCooTech on 8/13/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "Ticket.h"
#import "UserData.h"
#import <UIKit/UIKit.h>
#import "UILabel+Italicfy.h"
#import "NSDictionary+DataDictionary.h"
#import "WalletContents.h"

@interface Utilities : NSObject

+ (BOOL)isLightTheme;
+ (NSString *)apiHost;
+(NSString *)dev_ApiHost;
+ (NSString *)auth_host;
+ (NSString *)apiUrl;
+ (NSString *)apiEnvironment;
+ (NSString *)wsHost;
+ (NSString *)transitId;
+ (NSString *)authUsername;
+ (NSString *)authPassword;
+ (NSString *)urlencode:(NSString *)string;
+ (NSString *)accessToken;
+ (NSDictionary *)headers:(NSString *)url;
+ (NSString *)ipAddress;
+ (NSString *)deviceId;
+ (NSString *)appCurrentVersion;
+ (NSString *)walletId;
+ (NSString *)sessionId;
+ (NSString *)stringInfoForId:(NSString *)infoId;
+ (NSString *)stringResourceForId:(NSString *)resourceId;
+ (NSString *)colorHexStringFromId:(NSString *)resourceId;
+ (BOOL)featuresFromId:(NSString *)resourceId;
+ (NSString *)welcomeStringForUserData:(UserData *)userData;
//+ (BOOL)isValidEmail:(NSString *)email; //Were not using this at this time. We will instead pass it through to let Genfare handle providing us the error message to be displayed.
+ (NSTimeInterval)adjustmentForDaylightSavingsTime:(NSDate *)date fromReferenceDate:(NSDate *)refrenceDate;
+ (NSDate *)dateFromUTCString:(NSString *) inputString;
+ (BOOL)isTimeDuringServiceDay:(NSDate *)date usingManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)clearKeychainOnTheFirstRun;
+ (NSArray *)getCards:(NSManagedObjectContext *)managedObjectContext;
+ (Ticket *)currentTicket:(NSManagedObjectContext *)managedObjectContext;
+ (void)commitTickets:(NSString *)ticketSourceId managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (BOOL)setCurrentTicket:(NSString *)ticketSourceId
           ticketGroupId:(NSString *)ticketGroupId
                memberId:(NSString *)memberId
 firstActivationDateTime:(NSTimeInterval)firstActivationDateTime
    managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSMutableDictionary *)setMyAuthorizationHeaderFieldWithUsername:(NSString *)username
                                                          password:(NSString *)password
                                                               url:(NSString *)url;
+ (NSString *)stringToBase64:(NSString *)plainString;
+ (NSString *)commonaccessToken;
+ (NSString *)tenantId;
+ (float)statusBarHeight;
+ (UIViewController*)topMostController;
+ (void) popToRootViewController;
+(NSString *)capitalizedOnlyFirstLetter :(NSString *)plainString;
+ (NSString *)themeColor;
+ (NSString *)continueButtonBgColor;
+ (NSString *)tableBgColor;
+ (NSString *)textDarkColor;
+ (NSString *)buttonBGColor;
+ (NSString *)linkTextColor;
+ (NSString *)textInactiveColor;
+ (NSString *)pagerStripBgColor;
+ (NSString *)mainBgColor;
+ (NSString *)highLightColor;
+ (NSString *)tableViewHeaderBGColor;
+ (NSString *)ticketBorderColor;
+ (NSString *)bGColor;
+ (NSString *)pageMenuColor;
+ (NSString *)noPassesAlert;
+ (NSString *)noUsedTickets;
+ (NSString *)confirmLogoutTitle;
+ (NSString *)confirmLogoutMessage;
+ (NSString *)logoutButtonTitle;
+ (NSString *)cancelButtonTitle;
+ (NSString *)purchaseProductTitle;
+ (NSString *)purchaseProductMessage;
+ (NSString *)closeButtonTitle;
+ (NSString *)deleteCreditCardTitle;
+ (NSString *)deleteCreditCardMessage;
+ (NSString *)retriveCreditCardAlertTitle;
+ (NSString *)payAsYouGoAlertTitle;
+ (NSString *)payAsYouGoMessage;
+ (NSString *)walletUsingAlreadyMessage;
+ (NSString *)navigationBarTitle;
+ (NSString *)historyTitle;
+ (NSString *)createWalletTitle;
+ (NSString *)appstoreLink;
+ (NSString *)stagingLink;
+ (NSString *)uatLink;
+ (NSString *)topNavColor;





+ (NSString *)walletInstructionsViewController;
+ (NSString *)HelpViewController;
+ (NSString *)TermsViewController;
+ (NSString *)PrivacyViewController;
+ (NSString *)schedulesHost;
+(BOOL)isNetWorkAvailable;
+(CGFloat)currentDeviceHeight;
+ (NSString *)getValueFromDefaultsForKey:(NSString *)key;
+ (void)removeValueFromDefaults:(NSString *)key;
+ (void) saveAddress:(NSString *)address lat:(NSString *)lat long:(NSString *)longi for:(NSString *)type;
+ (NSString *)getObjectForLocation:(NSString *)location;
+ (NSDate *)getExpirationDateFromCurrentDate:(WalletContents* )walletContent;
+ (NSDate *)getActivationDate:(WalletContents* )walletContent;
+ (NSDate *)midNightCalculation:(WalletContents* )walletContent;
+ (NSDate *)calculateExpiryDate:(WalletContents* )walletContent;
+ (int)getCurrentWalletState:(NSManagedObjectContext *)managedObjectContext;

@end

