//
//  PutRegisteredDevice.m
//  Pods
//
//  Created by Andrey Kasatkin on 1/4/16.
//
//

#import "PutRegisteredDeviceService.h"
#import "Utilities.h"
#import "StoredData.h"


@implementation PutRegisteredDeviceService
{
    NSString* customPhoneName;
    NSString* mappingId;
    RegisteredDevice *currentDevice;
    
}

- (id)initWithListener:(id)listener
             mappingId:(NSString *)mapId
               newName:(NSString *)newN
      registeredDevice:(RegisteredDevice *)regDev
{
    self = [super init];
    if (self) {
        self.method = METHOD_PUT;
        self.listener = listener;
        mappingId = mapId;
        customPhoneName = newN;
        currentDevice = regDev;
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
    return [NSString stringWithFormat:@"accounts/devices/%@", mappingId];
}

- (NSDictionary *)createRequest
{
    NSDictionary *deviceDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      currentDevice.deviceUuid, @"uuid",
                                      @"Mobile", @"category",
                                      @"iOS", @"os",
                                      currentDevice.osVersion, @"os_version",
                                      currentDevice.model, @"model",
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
