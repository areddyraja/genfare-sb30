//
//  CDTAUtilities.m
//  CDTA
//
//  Created by CooCooTech on 9/24/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTAUtilities.h"
#import "Utilities.h"
#import "CooCooBase.h"
@implementation CDTAUtilities



+ (NSString *)schedulesHost
{
    return [Utilities schedulesHost];
}

+ (NSString *)schedulesKey
{
//    NSString *key =[[NSUserDefaults standardUserDefaults] objectForKey:KEY_ACCESS_TOKEN];
    NSString *key =[[NSUserDefaults standardUserDefaults] objectForKey:COMMON_KEY_ACCESS_TOKEN];
    return  key?key:@"";// [self stringInfoForId:@"schedules_key"];
}

+(NSString*)fetchScheduleKey{
    return [self stringInfoForId:@"schedules_key"];
}

+ (NSString *)stringInfoForId:(NSString *)infoId
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:infoId];
}

+ (NSString *)formatLocationName:(NSString *)locationName
{
    return [[locationName stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]
            stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\'"];
}

@end

