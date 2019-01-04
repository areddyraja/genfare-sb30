//
//  GetStationHashService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetStationHashService.h"
#import "AppConstants.h"
#import "Utilities.h"

@implementation GetStationHashService

- (id)initWithListener:(id)lis
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET;
        self.listener = lis;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities wsHost];
}

- (NSString *)uri
{
    return [NSString stringWithFormat:@"%@getStationHashForCarrier/%@", WS_PATH, [Utilities transitId]];
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *localStationsHash = [defaults stringForKey:KEY_LOCAL_STATIONS_HASH];
    
    if (![localStationsHash isEqualToString:serverResult]) {
        [defaults setObject:serverResult forKey:KEY_LOCAL_STATIONS_HASH];
        
        [defaults synchronize];
        
        return NO;
    } else {
        return YES;
    }
}

@end
