//
//  CDTAUtilities.h
//  CDTA
//
//  Created by CooCooTech on 9/24/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDTAUtilities : NSObject

+ (NSString *)schedulesHost;
+ (NSString *)schedulesKey;
+ (NSString *)formatLocationName:(NSString *)stopName;
+(NSString*)fetchScheduleKey;
@end
