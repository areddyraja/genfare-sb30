//
//  AppConstants.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "AppConstants.h"

NSString *const TYPE_APP = @"app";
NSString *const TYPE_DEVICE = @"iphone";
NSString *const TYPE_IPHONE = @"+iPhone+";

// NSUserDefaults
NSString *const KEY_DEFAULTS_INITIALIZED = @"defaultsInitialized";
NSString *const KEY_SESSION_ID = @"sessionId";
//NSString *const KEY_ACCESS_TOKEN = @"accessToken";
//NSString *const COMMON_KEY_ACCESS_TOKEN = @"commonaccessToken";
NSString *const COMMON_KEY_ACCESS_TOKEN = @"accessToken";
NSString *const USER_KEY_ACCESS_TOKEN = @"USER_KEY_ACCESS_TOKEN";
NSString *const WALLET_ID = @"WALLET_ID";
NSString *const KEY_LOCAL_STATIONS_HASH = @"localStationsHash";
NSString *const KEY_LAST_DEPART_STATION = @"lastDepartStation";
NSString *const KEY_LAST_ARRIVE_STATION = @"lastArriveStation";
NSString *const KEY_LAST_DEPART_CARRIER = @"lastDepartCarrier";
NSString *const KEY_LAST_ARRIVE_CARRIER = @"lastArriveCarrier";
NSString *const KEY_ENABLE_SPLIT_FLAP = @"enableSplitFlap";
NSString *const KEY_LAST_TOKEN_ACCESS = @"lastTokenAccess";
NSString *const REGEX_EMAIL = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
NSString *const KEY_SAVED_ADDRESS_HOME = @"kSavedAddressKeyForHome";
NSString *const KEY_SAVED_ADDRESS_WORK = @"kSavedAddressKeyForWork";
NSString *const KEY_SAVED_ADDRESS_SCHOOL = @"kSavedAddressKeyForSchool";
NSString *const PAY_AS_YOU_GO = @"1";

// Locales
NSString *const LOCALE = @"en_US";
double const APPROXIMATE_MILE = 0.0167;
double const MILES_PER_METER = 0.000621371;

// Time conversions
int const SECONDS_PER_MINUTE = 60;
int const SECONDS_PER_HOUR = 3600;

// UI settings
int const PAGER_STRIP_HEIGHT = 25;

// Services
NSString *const WS_PATH = @"CooCooWS/REST/";

// View controls
int const TAG_SPINNER = 266;

//TODO - changed helper height from 30 to 0 to hide the view
float const HELP_SLIDER_HEIGHT = 30;

@implementation AppConstants

@end

