//
//  AppConstants.h
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#define NSLog if(1) NSLog
@interface AppConstants : NSObject

typedef NS_ENUM(NSUInteger, WalletStatus) {
    WALLET_STATUS_UNKNOWN = 1,
    WALLET_STATUS_ACTIVE = 2,
    WALLET_STATUS_LOST = 3,
    WALLET_STATUS_STOLEN = 4,
    WALLET_STATUS_DAMAGED = 5,
    WALLET_STATUS_DEFECTIVE = 6,
    WALLET_STATUS_EXPIRED = 7,
    WALLET_STATUS_DISABLED = 8,
    WALLET_STATUS_SUSPENDED = 9,
    WALLET_STATUS_DEACTIVATED = 10,
    WALLET_STATUS_PENDING_DEACTIVATION = 11,
    WALLET_STATUS_PENDING_SUSPENSION = 12,
    WALLET_STATUS_PENDING_ACTIVATION = 13,
    WALLET_STATUS_INACTIVE = 14,
    WALLET_STATUS_UNAVAILABLE = 15,
    WALLET_STATUS_RESERVERD = 16,
    WALLET_STATUS_BAD_LISTED = 17,
    WALLET_STATUS_QUARANTINED = 18,
    WALLET_FARECODE_STATUS_EXPIRED = 19
};

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_ZOOMED (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

//Dynamic status bar height when connected to personal hot spot
#define STATUS_BAR_HEIGHT (UIApplication.sharedApplication.statusBarFrame.size.height)
#define NAVIGATION_BAR_HEIGHT (self.navigationController.navigationBar.frame.size.height)
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

FOUNDATION_EXPORT NSString *const TYPE_APP;
FOUNDATION_EXPORT NSString *const TYPE_DEVICE;
FOUNDATION_EXPORT NSString *const TYPE_IPHONE;

// NSUserDefaults
FOUNDATION_EXPORT NSString *const KEY_DEFAULTS_INITIALIZED;
FOUNDATION_EXPORT NSString *const KEY_SESSION_ID;
//FOUNDATION_EXPORT NSString *const KEY_ACCESS_TOKEN;
FOUNDATION_EXPORT NSString *const COMMON_KEY_ACCESS_TOKEN ;
FOUNDATION_EXPORT NSString *const WALLET_ID ;
FOUNDATION_EXPORT NSString *const USER_KEY_ACCESS_TOKEN;

FOUNDATION_EXPORT NSString *const KEY_LOCAL_STATIONS_HASH;
FOUNDATION_EXPORT NSString *const KEY_LAST_DEPART_STATION;
FOUNDATION_EXPORT NSString *const KEY_LAST_ARRIVE_STATION;
FOUNDATION_EXPORT NSString *const KEY_LAST_DEPART_CARRIER;
FOUNDATION_EXPORT NSString *const KEY_LAST_ARRIVE_CARRIER;
FOUNDATION_EXPORT NSString *const KEY_ENABLE_SPLIT_FLAP;
FOUNDATION_EXPORT NSString *const KEY_LAST_TOKEN_ACCESS;
FOUNDATION_EXPORT NSString *const REGEX_EMAIL;
FOUNDATION_EXPORT NSString *const KEY_SAVED_ADDRESS_HOME;
FOUNDATION_EXPORT NSString *const KEY_SAVED_ADDRESS_WORK;
FOUNDATION_EXPORT NSString *const KEY_SAVED_ADDRESS_SCHOOL;
FOUNDATION_EXPORT NSString *const PAY_AS_YOU_GO; //AppConstants.h

// Locales
FOUNDATION_EXPORT NSString *const LOCALE;
FOUNDATION_EXPORT double const APPROXIMATE_MILE;
FOUNDATION_EXPORT double const MILES_PER_METER;

// Time conversions
FOUNDATION_EXPORT int const SECONDS_PER_MINUTE;
FOUNDATION_EXPORT int const SECONDS_PER_HOUR;

// UI settings
FOUNDATION_EXPORT int const PAGER_STRIP_HEIGHT;

// Services
FOUNDATION_EXPORT NSString *const WS_PATH;

// View controls
FOUNDATION_EXPORT int const TAG_SPINNER;

FOUNDATION_EXPORT float const HELP_SLIDER_HEIGHT;

@end

