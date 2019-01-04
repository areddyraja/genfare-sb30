//
//  GetCDTASchedulesService.m
//  CDTA
//
//  Created by CooCooTech on 11/13/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetCDTASchedulesService.h"
#import "CDTAUtilities.h"

@implementation GetCDTASchedulesService
{
    int routeId;
    NSString *serviceType;
}

- (id)initWithListener:(id)listener
               routeId:(int)route
           serviceType:(NSString *)type
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
        routeId = route;
        serviceType = type;
        self.managedObjectContext = context;
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
    return [NSString stringWithFormat:@"api/v1/?request=schedules/%d/%@", routeId, serviceType];
}

- (NSDictionary *)headers
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    [headers setObject:[CDTAUtilities fetchScheduleKey] forKey:@"key"];
    
    return headers;
}

- (NSDictionary *)createRequest
{
    return nil;
}

// TODO: Needed?
- (BOOL)processResponse:(id)serverResult
{
    NSLog(@"SCHEDZ: %@", serverResult);
    
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ((json != nil) && [json count] > 0) {
        
        return YES;
    }
    
    return NO;
}

@end
