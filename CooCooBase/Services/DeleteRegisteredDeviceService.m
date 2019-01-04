//
//  DeleteRegisteredDeviceService.m
//  Pods
//
//  Created by Andrey Kasatkin on 12/2/15.
//
//

#import "DeleteRegisteredDeviceService.h"
#import "Utilities.h"

@implementation DeleteRegisteredDeviceService
{
    NSNumber *mappingId;
}

- (id)initWithListener:(id)lis mappingId:(NSNumber *)mapId
{
    self = [super init];
    if (self) {
        self.method = METHOD_DELETE;
        self.listener = lis;
        mappingId = mapId;
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
    return [NSString stringWithFormat:@"accounts/devices/%@",[mappingId stringValue] ];
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
