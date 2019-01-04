//
//  RegisterDeviceService.m
//  CooCooBase
//
//  Created by CooCooTech on 6/23/14.
//   Updated AK on 11/1/15
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "RegisterDeviceService.h"
#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "StoredData.h"

@implementation RegisterDeviceService
{
    NSString* customPhoneName;
}

- (id)initWithListener:(id)lis customName:(NSString *)customName
{
    self = [super init];
    if (self) {
        self.listener = lis;
        customPhoneName = customName;
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
    return @"accounts/devices";
}

- (NSDictionary *)createRequest
{
    UIDevice *device = [UIDevice currentDevice];
    
    NSDictionary *deviceDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [Utilities deviceId], @"uuid",
                                      @"Mobile", @"category",
                                      @"iOS", @"os",
                                      device.systemVersion, @"os_version",
                                      device.model, @"model",
                                      nil];
    
    NSDictionary *accountDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [StoredData userData].accountId, @"uuid",
                                       nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], @"app_version",
            customPhoneName, @"name",
            deviceDictionary, @"device",
            accountDictionary, @"account",
            nil];
            
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        return YES;
    } else {
               
    }

    return NO;
}

@end
