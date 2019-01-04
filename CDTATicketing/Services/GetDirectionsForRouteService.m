//
//  GetDirectionsForRouteService.m
//  CDTA
//
//  Created by CooCooTech on 11/13/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetDirectionsForRouteService.h"
#import "CDTAUtilities.h"
#import "Route.h"
#import "RouteDirection.h"
#import "Utilities.h"

@implementation GetDirectionsForRouteService
{
    int routeId;
}

- (id)initWithListener:(id)listener
               routeId:(int)route
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
        routeId = route;
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
    return [NSString stringWithFormat:@"api/v1/?request=directions/%d", routeId];
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
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ((json != nil) && [json count] > 0) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:ROUTE_MODEL
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"routeId == %d", routeId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *matchingRoutes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([matchingRoutes count] > 0) {
            Route *route = [matchingRoutes objectAtIndex:0];
            
            NSMutableArray *routeDirections = [[NSMutableArray alloc] init];
            
            NSArray *directions = [json objectForKey:@"directions"];
            for (NSDictionary *directionJson in directions) {
                RouteDirection *routeDirection = [[RouteDirection alloc] init];
                [routeDirection setDirectionId:[[directionJson objectForKey:@"id"] intValue]];
                [routeDirection setName:[directionJson objectForKey:@"direction"]];
                [routeDirection setScheduleUri:[directionJson objectForKey:@"route_schedule_uri"]];
                
                [routeDirections addObject:routeDirection];
            }
            
            NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:routeDirections];
            
            [route setDirections:arrayData];
            
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
            }
            
            return YES;
        }
    }
    
    return NO;
}

@end
