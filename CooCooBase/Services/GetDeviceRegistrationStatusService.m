//
//  GetDeviceRegistrationStatusService.m
//  CooCooBase
//
//  Created by John Scuteri on 9/10/14.
//  Updated by AK on 11/1/15
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "GetDeviceRegistrationStatusService.h"
#import "RegisteredDevice.h"
#import "RuntimeData.h"
#import "Utilities.h"

@implementation GetDeviceRegistrationStatusService
{
    NSString *accountId;
}

- (id)initWithListener:(id)lis
             accountId:(NSString *)account
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = lis;
        accountId = account;
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
    return [NSString stringWithFormat:@"accounts/devices?accountUuid=%@&active=true", accountId];
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
    NSMutableArray *deviceRegistrations = [[NSMutableArray alloc] init];
    
    for (NSDictionary *deviceJson in json) {
        RegisteredDevice *registeredDevice = [[RegisteredDevice alloc] init];
        
        [registeredDevice setMappingId:[NSNumber numberWithInt:[[deviceJson objectForKey:@"id"] intValue]]];
        [registeredDevice setAppVersion:[deviceJson objectForKey:@"app_version"]];
        [registeredDevice setCategory:[[deviceJson objectForKey:@"device"] objectForKey:@"category"]];
        [registeredDevice setDeviceId:[NSNumber numberWithInt:[[[deviceJson objectForKey:@"device"] objectForKey:@"id" ] intValue]]];
        [registeredDevice setDeviceUuid:[[deviceJson objectForKey:@"device"] objectForKey:@"uuid"]];
        [registeredDevice setOs:[[deviceJson objectForKey:@"device"] objectForKey:@"os"]];
        [registeredDevice setOsVersion:[[deviceJson objectForKey:@"device"] objectForKey:@"os_version"]];
        [registeredDevice setModel:[[deviceJson objectForKey:@"device"] objectForKey:@"model"]];
        [registeredDevice setName:[deviceJson objectForKey:@"name"]];
        [registeredDevice setCreated:[Utilities dateFromUTCString:[deviceJson objectForKey:@"created"]]];
        [registeredDevice setActive:[[deviceJson objectForKey:@"active"] boolValue]];
        [registeredDevice setAccountId:[NSNumber numberWithInt:[[[deviceJson objectForKey:@"account"] objectForKey:@"id"] intValue]]];
        [registeredDevice setIsPrimary:[[deviceJson objectForKey:@"primary"] boolValue]];
        
        [deviceRegistrations addObject:registeredDevice];
    }
    
    [[RuntimeData instance] setRegisteredDevices:deviceRegistrations];
}

@end
