//
//  UsageLoggingService.m
//  CDTA
//
//  Created by CooCooTech on 12/4/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "UsageLoggingService.h"
#import "CDTAUtilities.h"

@implementation UsageLoggingService
{
    NSString *endpoint;
    NSString *viewName;
    NSString *viewDetails;
    double latitude;
    double longitude;
}

- (id)initWithEndpoint:(NSString *)point
              viewName:(NSString *)name
           viewDetails:(NSString *)details
              latitude:(double)lat
             longitude:(double)lng;
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_POST;
        endpoint = point;
        
        if ([name length] > 0) {
            viewName = name;
        } else {
            viewName = @"";
        }
        
        if ([details length] > 0) {
            viewDetails = details;
        } else {
            viewDetails = @"";
        }
        
        latitude = lat;
        longitude = lng;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [CDTAUtilities schedulesHost];
}

- (NSString *)uri
{
    return [NSString stringWithFormat:@"api/v1/?request=%@", endpoint];
}

- (NSDictionary *)headers
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    [headers setObject:[CDTAUtilities fetchScheduleKey] forKey:@"key"];
    NSString * currentAppVersion = [Utilities appCurrentVersion];
    [headers setValue:@"iOS" forKey:@"app_os"];
    [headers setValue:currentAppVersion forKey:@"app_version"];
    
    
    return headers;
}

- (NSDictionary *)createRequest
{
    NSDictionary *requestParameters = nil;
    
    if ([endpoint isEqualToString:@"appstart"]) {
        requestParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"ios%@", [[UIDevice currentDevice] systemVersion]], @"os_name",
                             @"iphone", @"phone_model",
                             [Utilities deviceId], @"device_id",
                             [NSString stringWithFormat:@"v%@", [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]], @"app_version",
                             [NSNumber numberWithDouble:latitude], @"latitude",
                             [NSNumber numberWithDouble:longitude], @"longitude",
                             nil];
    } else {
        requestParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                             viewName, @"view_name",
                             viewDetails, @"view_details",
                             [Utilities deviceId], @"device_id",
                             nil];
    }
    
    return requestParameters;
}

- (BOOL)processResponse:(id)serverResult
{
    return true;
}

@end
